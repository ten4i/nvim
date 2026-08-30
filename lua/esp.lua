local M = {}

local PORT = "/dev/ttyUSB0"
local IDF_EXPORT = vim.fn.expand("$HOME/EspIdfToolchain/export.sh")
local SCRIPT = vim.fn.expand("$HOME/Scripts/IdfSyncUpload.sh")

-- Target chip is NOT chosen here. ESP-IDF stores it per-project in
-- sdkconfig via `idf.py set-target` (see M.set_target) — pass it once
-- per project / when switching chips, not on every build.

-- Toolchains actually installed (via install.sh esp32,esp32s3). Add more
-- here after running `~/EspIdfToolchain/install.sh <target>`.
local IDF_TARGETS = { "esp32", "esp32s3" }

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO)
end

local function current_file()
  local file = vim.fn.expand("%:p")
  if file == "" then
    notify("No file in current buffer", vim.log.levels.ERROR)
    return nil
  end
  return file
end

-- Walk up from the current file to the ESP-IDF project root: the
-- CMakeLists.txt that pulls in project.cmake, not a component's own
-- CMakeLists.txt (e.g. main/CMakeLists.txt).
local function project_root()
  local file = current_file()
  if not file then
    return nil
  end

  local found = vim.fs.find(function(name, path)
    if name ~= "CMakeLists.txt" then
      return false
    end
    for _, line in ipairs(vim.fn.readfile(path .. "/" .. name)) do
      if line:match("project%.cmake") then
        return true
      end
    end
    return false
  end, { path = vim.fn.fnamemodify(file, ":h"), upward = true, type = "file" })

  if #found == 0 then
    notify("No ESP-IDF project root found above " .. file, vim.log.levels.ERROR)
    return nil
  end
  return vim.fn.fnamemodify(found[1], ":h")
end

local function run(cmd, on_exit)
  vim.cmd("tabnew")
  if on_exit then
    vim.fn.termopen(cmd, { on_exit = function(_, code) on_exit(code) end })
  else
    vim.fn.termopen(cmd)
  end
  vim.cmd("startinsert")
end

local function read_target(root)
  local sdkconfig = root .. "/sdkconfig"
  if vim.fn.filereadable(sdkconfig) == 0 then
    return nil
  end
  for _, line in ipairs(vim.fn.readfile(sdkconfig)) do
    local t = line:match('^CONFIG_IDF_TARGET="(.+)"$')
    if t then
      return t
    end
  end
  return nil
end

-- Ask esptool what's actually plugged into PORT. Returns an IDF target
-- string (e.g. "esp32s3") or nil + raw esptool output on failure.
local function detect_connected_chip()
  local cmd = string.format(
    "bash -c %s",
    vim.fn.shellescape(string.format(
      ". %s > /dev/null 2>&1 && esptool.py --port %s chip_id 2>&1",
      IDF_EXPORT, PORT
    ))
  )
  local output = vim.fn.system(cmd)
  local chip = output:match("Detecting chip type%.%.%.%s*(%S+)")
  if not chip then
    return nil, output
  end
  return (chip:lower():gsub("%-", "")), output
end

local function on_sync_exit(what)
  return function(code)
    if code ~= 0 then
      notify(what .. " failed", vim.log.levels.ERROR)
      return
    end
    notify(what .. " OK, .clangd refreshed")
    vim.defer_fn(function()
      vim.cmd("CocRestart")
    end, 500)
  end
end

-- idf.py build + refresh compile_commands.json/.clangd, no flashing
function M.build()
  local root = project_root()
  if not root then
    return
  end
  notify("idf.py build: " .. root)
  local cmd = string.format("%s %s", vim.fn.shellescape(SCRIPT), vim.fn.shellescape(root))
  run(cmd, on_sync_exit("Build"))
end

-- build, then flash (no monitor)
function M.flash()
  local root = project_root()
  if not root then
    return
  end
  notify("Build + flash: " .. root)
  local cmd = string.format(
    "%s --flash --port %s %s",
    vim.fn.shellescape(SCRIPT), vim.fn.shellescape(PORT), vim.fn.shellescape(root)
  )
  run(cmd, on_sync_exit("Flash"))
end

-- build, flash, then attach the serial monitor. Auto-detects the chip
-- actually plugged into PORT (via esptool) and compares it against the
-- project's current sdkconfig target: same chip -> straight to build+
-- flash+monitor, different chip -> ask which board (list on top),
-- rebuild for it, then flash+monitor.
function M.upload()
  local root = project_root()
  if not root then
    return
  end

  local function do_upload(target)
    notify("Build + flash + monitor (" .. target .. "): " .. root)
    local cmd = string.format(
      "%s --target %s --flash --monitor --port %s %s",
      vim.fn.shellescape(SCRIPT), vim.fn.shellescape(target),
      vim.fn.shellescape(PORT), vim.fn.shellescape(root)
    )
    run(cmd)
  end

  notify("Detecting board on " .. PORT .. "...")
  local detected = detect_connected_chip()
  if not detected then
    notify("Could not detect a board on " .. PORT .. " (check it's plugged in / port is correct)", vim.log.levels.ERROR)
    return
  end

  local current = read_target(root)
  if detected == current then
    do_upload(detected)
    return
  end

  local options = { detected }
  for _, t in ipairs(IDF_TARGETS) do
    if t ~= detected then
      table.insert(options, t)
    end
  end

  vim.ui.select(options, {
    prompt = string.format(
      "Project is set to '%s' but detected '%s' on %s — pick target:",
      current or "unset", detected, PORT
    ),
  }, function(choice)
    if not choice then
      return
    end
    do_upload(choice)
  end)
end

-- serial monitor only, no build/flash
function M.monitor()
  local cmd = string.format(
    "bash -c %s",
    vim.fn.shellescape(string.format(
      ". %s > /dev/null 2>&1 && idf.py -p %s monitor",
      IDF_EXPORT, PORT
    ))
  )
  run(cmd)
end

function M.menuconfig()
  local root = project_root()
  if not root then
    return
  end
  local cmd = string.format(
    "bash -c %s",
    vim.fn.shellescape(string.format(
      ". %s > /dev/null 2>&1 && cd %s && idf.py menuconfig",
      IDF_EXPORT, vim.fn.shellescape(root)
    ))
  )
  run(cmd)
end

-- idf.py set-target <chip>, then rebuild (regenerates sdkconfig,
-- compile_commands.json and .clangd for the new chip)
function M.set_target()
  local root = project_root()
  if not root then
    return
  end
  vim.ui.input({ prompt = "IDF target (esp32, esp32s3, esp32c3, ...): " }, function(target)
    if not target or target == "" then
      return
    end
    notify("set-target " .. target .. ": " .. root)
    local cmd = string.format(
      "%s --target %s %s",
      vim.fn.shellescape(SCRIPT), vim.fn.shellescape(target), vim.fn.shellescape(root)
    )
    run(cmd, on_sync_exit("set-target " .. target))
  end)
end

return M
