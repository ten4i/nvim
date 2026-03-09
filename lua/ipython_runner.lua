local M = {}

local function ipython_alive()
  return vim.g.ipython_job_id
    and vim.fn.jobwait({ vim.g.ipython_job_id }, 0)[1] == -1
end

local function ensure_ipython(callback)
  if ipython_alive() then
    callback(vim.g.ipython_job_id)
    return
  end

  vim.cmd("belowright 20split")
  vim.cmd("terminal ipython")

  vim.defer_fn(function()
    vim.g.ipython_job_id = vim.b.terminal_job_id
    callback(vim.g.ipython_job_id)
  end, 150)
end

local function jump_to_ipython()
  vim.defer_fn(function()
    vim.cmd("BufferNext")
    vim.cmd("startinsert!")
  end, 80)
end

local function send_block(code)
  ensure_ipython(function(job_id)
    vim.fn.chansend(job_id, "%cpaste\n")
    vim.defer_fn(function()
      vim.fn.chansend(job_id, code .. "\n--\n")
      jump_to_ipython()
    end, 120)
  end)
end

function M.send_selection()
  local source_buf = vim.api.nvim_get_current_buf()
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")
  local lines = vim.api.nvim_buf_get_lines(source_buf, start_line - 1, end_line, false)
  local code = table.concat(lines, "\n")

  send_block(code)
end

function M.run_line()
  local line = vim.api.nvim_get_current_line()

  ensure_ipython(function(job_id)
    vim.fn.chansend(job_id, line .. "\r")
    jump_to_ipython()
  end)
end

function M.run_file()
  local source_buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(source_buf, 0, -1, false)
  local code = table.concat(lines, "\n")

  send_block(code)
end

return M
