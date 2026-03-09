local M = {}

local serial_cmd = "arduino-cli monitor -p /dev/ttyUSB0 -c baudrate=9600"

function M.serial()
  vim.cmd("terminal " .. serial_cmd)
end

function M.serial_restart()
  for _, buf in ipairs(vim.fn.getbufinfo({bufloaded = 1})) do
    if buf.name:match("arduino%-cli.*monitor") then
      vim.cmd("bdelete! " .. buf.bufnr)
    end
  end

  vim.cmd("terminal " .. serial_cmd)
end

function M.sync()
  local ino = vim.fn.expand("%:p")
  local dir = vim.fn.fnamemodify(ino, ":h")

  local cmd = "cd " .. dir .. " && ./arduino-sync.sh " .. ino

  local result = vim.fn.system(cmd)

  print(result)
  print("✔ File synchronized")
end

function M.upload()
  local file = vim.fn.expand("%:p")
  local dir = vim.fn.fnamemodify(file, ":h")

  local cmd =
    "arduino-cli compile --upload " ..
    -- nano old bootloader
    "--fqbn arduino:avr:nano:cpu=atmega328old " ..
    -- nano 
    -- "--fqbn arduino:avr:nano" ..
    -- uno 
    -- "--fqbn arduino:avr:uno" ..
    -- mega
    -- "--fqbn arduino:avr:mega" ..
    "-p /dev/ttyUSB0 " ..
    dir

  vim.cmd("terminal " .. cmd)
end
return M
