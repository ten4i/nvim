local M = {}

local port = "/dev/ttyUSB0"

-- Board presets. ESP32 is intentionally NOT here: those projects use ESP-IDF (idf.py), not arduino-cli.
local avr_includes = {
  "/usr/lib/gcc/avr/5.4.0/include",
  "/usr/lib/gcc/avr/5.4.0/include-fixed",
  "/usr/lib/gcc/avr/5.4.0/../../../avr/include",
}

local boards = {
  nano = { fqbn = "arduino:avr:nano:cpu=atmega328", baud = "9600", includes = avr_includes },
  nano_old = { fqbn = "arduino:avr:nano:cpu=atmega328old", baud = "9600", includes = avr_includes },
  uno = { fqbn = "arduino:avr:uno", baud = "9600", includes = avr_includes },
  mega = { fqbn = "arduino:avr:mega:cpu=atmega2560", baud = "9600", includes = avr_includes },
  promini = { fqbn = "arduino:avr:pro:cpu=16MHzatmega328", baud = "9600", includes = avr_includes },
  esp8266 = {
    fqbn = "esp8266:esp8266:generic",
    baud = "115200",
    includes = {
      "/home/ten4i/.arduino15/packages/esp8266/tools/xtensa-lx106-elf-gcc/3.1.0-gcc10.3-e5f9fec/include",
      "/home/ten4i/.arduino15/packages/esp8266/tools/xtensa-lx106-elf-gcc/3.1.0-gcc10.3-e5f9fec/xtensa-lx106-elf/include",
    },
  },
}

local default_board = "nano_old"
-- Remembers the chosen board per project directory, so switching sketches doesn't
-- reset the selection back to default_board.
local project_board = {}

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

local function current_dir()
  local file = current_file()
  if not file then
    return nil
  end
  return vim.fn.fnamemodify(file, ":h")
end

-- Reads default_fqbn from the sketch's sketch.yaml (created by `arduino-cli board attach`)
-- and returns the preset name whose core:arch:board matches it.
local function board_from_sketch_yaml(dir)
  local f = io.open(dir .. "/sketch.yaml", "r")
  if not f then
    return nil
  end
  local content = f:read("*a")
  f:close()

  local fqbn = content:match("default_fqbn:%s*([^%s]+)")
  if not fqbn then
    return nil
  end

  -- Exact match first: nano and nano_old differ only in the cpu= option.
  for name, board in pairs(boards) do
    if board.fqbn == fqbn then
      return name
    end
  end

  local function short(v)
    return table.concat(vim.list_slice(vim.split(v, ":", { plain = true }), 1, 3), ":")
  end
  for name, board in pairs(boards) do
    if short(board.fqbn) == short(fqbn) then
      return name
    end
  end
end

local function board_for(dir)
  local name = project_board[dir] or board_from_sketch_yaml(dir) or default_board
  return name, boards[name]
end

function M.board()
  local dir = current_dir()
  if not dir then
    return
  end

  local names = vim.tbl_keys(boards)
  table.sort(names)

  vim.ui.select(names, { prompt = "Arduino board for " .. vim.fn.fnamemodify(dir, ":t") }, function(choice)
    if not choice then
      return
    end
    project_board[dir] = choice
    -- Persist the choice in sketch.yaml so it survives restarting nvim.
    vim.fn.system({ "arduino-cli", "board", "attach", "-b", boards[choice].fqbn, dir })
    notify("Board set to " .. choice .. " (" .. boards[choice].fqbn .. ")")
  end)
end

local function write_clangd(dir, board)
  local clangd_path = dir .. "/.clangd"
  -- .ino has no #include <Arduino.h>; arduino-cli adds it only in the generated build/sketch/*.ino.cpp.
  local lines = { "CompileFlags:", "  Add: [", '    "-include", "Arduino.h",' }
  for i, inc in ipairs(board.includes) do
    local suffix = i < #board.includes and "," or ""
    table.insert(lines, string.format('    "-isystem", "%s"%s', inc, suffix))
  end
  table.insert(lines, "  ]")
  vim.fn.writefile(lines, clangd_path)
end

function M.serial()
  local dir = current_dir()
  local _, board = board_for(dir or "")
  local baud = board and board.baud or "9600"

  local cmd = string.format(
    "arduino-cli monitor -p %s -c baudrate=%s",
    vim.fn.shellescape(port),
    vim.fn.shellescape(baud)
  )
  vim.cmd("terminal " .. cmd)
end

function M.serial_restart()
  for _, buf in ipairs(vim.fn.getbufinfo({ bufloaded = 1 })) do
    if buf.name:match("arduino%-cli.*monitor") then
      vim.cmd("bdelete! " .. buf.bufnr)
    end
  end

  M.serial()
end

function M.sync()
  vim.cmd("write")

  local dir = current_dir()
  if not dir then
    return
  end

  if vim.fn.executable("arduino-cli") ~= 1 then
    notify("arduino-cli not found in PATH", vim.log.levels.ERROR)
    return
  end

  local board_name, board = board_for(dir)

  local build_dir = dir .. "/build"
  local db_src = build_dir .. "/compile_commands.json"
  local db_dst = dir .. "/compile_commands.json"

  notify("Arduino sync started (" .. board_name .. ")...")

  vim.fn.jobstart({
    "arduino-cli",
    "compile",
    "--no-color",
    "--fqbn", board.fqbn,
    "--only-compilation-database",
    "--build-path", build_dir,
    dir,
  }, {
    cwd = dir,
    stdout_buffered = true,
    stderr_buffered = true,

    on_stderr = function(_, data)
      if not data then
        return
      end
      local msg = table.concat(data, "\n"):gsub("^%s+", ""):gsub("%s+$", "")
      if msg ~= "" then
        vim.schedule(function()
          notify(msg, vim.log.levels.ERROR)
        end)
      end
    end,

    on_exit = function(_, code)
      vim.schedule(function()
        if code ~= 0 then
          notify("Arduino sync failed", vim.log.levels.ERROR)
          return
        end

        if vim.fn.filereadable(db_src) == 0 then
          notify("build/compile_commands.json was not generated", vim.log.levels.ERROR)
          return
        end

        vim.fn.delete(db_dst)

        local lines = vim.fn.readfile(db_src)
        if vim.tbl_isempty(lines) then
          notify("compile_commands.json is empty", vim.log.levels.ERROR)
          return
        end

        vim.fn.writefile(lines, db_dst)

        if vim.fn.filereadable(db_dst) == 0 then
          notify("failed to create compile_commands.json", vim.log.levels.ERROR)
          return
        end

        write_clangd(dir, board)

        notify("Arduino sync done")

        vim.defer_fn(function()
          vim.cmd("CocRestart")
        end, 800)
      end)
    end,
  })
end

function M.upload()
  vim.cmd("write")

  local dir = current_dir()
  if not dir then
    return
  end

  if vim.fn.executable("arduino-cli") ~= 1 then
    notify("arduino-cli not found in PATH", vim.log.levels.ERROR)
    return
  end

  local board_name, board = board_for(dir)
  local build_dir = dir .. "/build"

  local cmd = table.concat({
    "arduino-cli compile --upload",
    "--no-color",
    "--fqbn " .. vim.fn.shellescape(board.fqbn),
    "--build-path " .. vim.fn.shellescape(build_dir),
    "-p " .. vim.fn.shellescape(port),
    vim.fn.shellescape(dir),
  }, " ")

  local project_name = vim.fn.fnamemodify(dir, ":t")
  vim.cmd("botright 12split")
  vim.cmd("terminal " .. cmd)
  vim.cmd("file " .. project_name .. "_upload_" .. board_name)
  vim.cmd("startinsert")
end

-- ==========================================================
vim.api.nvim_create_augroup("arduino_cpp", { clear = true })

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = "arduino_cpp",
  pattern = "*.ino",
  callback = function()
    vim.bo.filetype = "cpp"
  end,
})
-- ==========================================================

return M
