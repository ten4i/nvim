local M = {}

local PORT = "/dev/ttyUSB0"

-- =========================
-- CHANGE HERE (toggle)
-- =========================

local BOARD = "esp32cam"
-- local BOARD = "esp32"
-- local BOARD = "esp01"


-- for compiling only comand use in terminal
-- esp --no-upload <name>.ino
-- boards: esp01, esp32, esp32cam

-- =========================

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

  local cmd = string.format("esp --board %s %s", BOARD, file)

  vim.notify("Upload → " .. BOARD)
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
