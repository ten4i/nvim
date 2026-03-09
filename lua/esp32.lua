local M = {}

function M.upload()

  local file = vim.fn.expand("%:p")
  local dir  = vim.fn.fnamemodify(file, ":h")

  vim.cmd("tabnew")

  vim.fn.termopen(
    { dir .. "/Esp32SyncUpload.sh", file },
    { cwd = dir }
  )

  vim.cmd("startinsert")

end


function M.monitor()

  vim.cmd("tabnew | terminal arduino-cli monitor -p /dev/ttyUSB0 -c baudrate=115200")

end

return M
