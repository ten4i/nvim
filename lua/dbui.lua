local M = {}

vim.g.db_ui_winwidth = 35

-- Build dbs list from env var at startup
vim.g.dbs = {
  { name = "ShopDB", url = "mysql://btbw:" .. (vim.env.MYSQL_PASS or "") .. "@192.168.1.120:3306/ShopDB" },
}

-- SQL buffer settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "sql",
  callback = function() vim.opt_local.wrap = true end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "dbout", "mysql" },
  callback = function() vim.opt_local.wrap = true end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.sql",
  callback = function() vim.opt_local.wrap = true end,
})

return M
