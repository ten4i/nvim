local function fix_signcolumn()
  vim.api.nvim_set_hl(0, "SignColumn",   { bg = "none" })
  vim.api.nvim_set_hl(0, "SignColumnNC", { bg = "none" })

  vim.api.nvim_set_hl(0, "DiagnosticSignError", { fg = "#ff6b6b", bg = "none" })
  vim.api.nvim_set_hl(0, "DiagnosticSignWarn",  { fg = "#feca57", bg = "none" })
  vim.api.nvim_set_hl(0, "DiagnosticSignInfo",  { fg = "#54a0ff", bg = "none" })
  vim.api.nvim_set_hl(0, "DiagnosticSignHint",  { fg = "#1dd1a1", bg = "none" })
end

-- применяем сразу
fix_signcolumn()

-- и при смене темы
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = fix_signcolumn,
})

