local M = {}

vim.g.db_ui_winwidth = 35

-- Build dbs list from env var at startup
vim.g.dbs = {
  { name = "ShopDB", url = "mysql://btbw:" .. (vim.env.MYSQL_PASS or "") .. "@192.168.1.120:3306/ShopDB" },
}

-- Toggle sidebar
vim.keymap.set("n", "<leader>db", "<cmd>DBUIToggle<CR>", { silent = true, desc = "DBUI toggle" })

-- Connect current sql buffer to a chosen database
local function connect_db()
  local dbname = vim.fn.input("Database (empty = no db): ")
  local url = "mysql://btbw:" .. (vim.env.MYSQL_PASS or "") .. "@192.168.1.120:3306/" .. dbname
  vim.b.db = url
  local label = dbname == "" and "MySQL server (no db)" or dbname
  vim.notify(" Connected to " .. label)
end

vim.keymap.set("n", "<leader>dc", connect_db, { desc = "DBUI connect" })

-- SQL buffer mappings and settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "sql",
  callback = function()
    local opts = { buffer = true, silent = true }

    -- execute visual selection
    vim.keymap.set("x", "<leader>e", function()
      local db = vim.b.db or vim.g.db or ""
      vim.cmd("'<,'>DB " .. db)
    end, opts)

    -- execute current line
    vim.keymap.set("n", "<leader>e", function()
      local db = vim.b.db or vim.g.db or ""
      vim.cmd(".DB " .. db)
    end, opts)

    -- execute whole file
    vim.keymap.set("n", "<leader>S", function()
      local db = vim.b.db or vim.g.db or ""
      vim.cmd("%DB " .. db)
    end, opts)

    vim.opt_local.wrap = true
  end,
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
