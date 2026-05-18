vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    local buf = vim.api.nvim_get_current_buf()

    -- немного подождать, пока терминал запустится
    vim.defer_fn(function()
      local lines = vim.api.nvim_buf_get_lines(buf, 0, 20, false)
      local content = table.concat(lines, " ")

      if content:match("Claude") or content:match("claude") then
        vim.api.nvim_buf_set_name(buf, " claude")
      elseif content:match("IPython") or content:match("ipython") then
        vim.api.nvim_buf_set_name(buf, " ipython")
      else
        vim.api.nvim_buf_set_name(buf, " terminal")
      end
    end, 100)
  end,
})
