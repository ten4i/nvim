local M = {}

local PORT = "/dev/ttyUSB0"
local SCRIPT_NAME = "EspSyncUpload.sh"

-- Board is NOT chosen here. Each project's own EspSyncUpload.sh
-- (in the same dir as the .ino) has its own BOARD default at the
-- top of the file — edit it there per project.

local function get_file()
  local file = vim.fn.expand("%:p")
  if file == "" then
    vim.notify("No file", vim.log.levels.ERROR)
    return nil
  end
  return file
end

local function run(cmd)
  vim.cmd("tabnew")
  vim.fn.termopen(cmd)
  vim.cmd("startinsert")
end

function M.upload()
  local file = get_file()
  if not file then return end

  local dir = vim.fn.fnamemodify(file, ":h")
  local script = dir .. "/" .. SCRIPT_NAME

  if vim.fn.filereadable(script) == 0 then
    vim.notify("No " .. SCRIPT_NAME .. " in " .. dir, vim.log.levels.ERROR)
    return
  end

  local cmd = string.format("%s %s", vim.fn.shellescape(script), vim.fn.shellescape(file))

  vim.notify("Upload via " .. script)
  run(cmd)
end

function M.monitor()
  local cmd = string.format(
    "arduino-cli monitor -p %s -c baudrate=115200",
    PORT
  )

  run(cmd)
end

return M
