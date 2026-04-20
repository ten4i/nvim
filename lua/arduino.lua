local M = {}

local port = "/dev/ttyUSB0"
local fqbn = "arduino:avr:nano:cpu=atmega328old"
local baud = "9600"

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

local function write_clangd(dir)
  local clangd_path = dir .. "/.clangd"
  local lines = {
    "CompileFlags:",
    "  Add: [",
    '    "-isystem", "/usr/lib/gcc/avr/5.4.0/include",',
    '    "-isystem", "/usr/lib/gcc/avr/5.4.0/include-fixed",',
    '    "-isystem", "/usr/lib/gcc/avr/5.4.0/../../../avr/include"',
    "  ]",
  }
  vim.fn.writefile(lines, clangd_path)
end

function M.serial()
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

  local build_dir = dir .. "/build"
  local db_src = build_dir .. "/compile_commands.json"
  local db_dst = dir .. "/compile_commands.json"

  notify("Arduino sync started...")

  vim.fn.jobstart({
    "arduino-cli",
    "compile",
    "--no-color",
    "--fqbn", fqbn,
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

        write_clangd(dir)

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

  local build_dir = dir .. "/build"

  local cmd = table.concat({
    "arduino-cli compile --upload",
    "--no-color",
    "--fqbn " .. vim.fn.shellescape(fqbn),
    "--build-path " .. vim.fn.shellescape(build_dir),
    "-p " .. vim.fn.shellescape(port),
    vim.fn.shellescape(dir),
  }, " ")

local project_name = vim.fn.fnamemodify(dir, ":t")
  vim.cmd("botright 12split")
  vim.cmd("terminal " .. cmd)
  vim.cmd("file " .. project_name .. "_upload")
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
