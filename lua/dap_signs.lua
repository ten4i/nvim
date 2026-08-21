vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"

vim.fn.sign_define("DapBreakpoint",          { text = "B", texthl = "DapBreakpoint" })
vim.fn.sign_define("DapBreakpointCondition",{ text = "B", texthl = "DapBreakpointCondition" })
vim.fn.sign_define("DapLogPoint",            { text = "L", texthl = "DapLogPoint" })
vim.fn.sign_define("DapStopped",             { text = "▶", texthl = "DapStopped", linehl = "DapStoppedLine" })
vim.fn.sign_define("DapBreakpointRejected", { text = "B", texthl = "DapBreakpointRejected" })

local function set_dap_highlights()
  vim.api.nvim_set_hl(0, "DapBreakpoint",          { fg = "#55FF55", bg = "none" })
  vim.api.nvim_set_hl(0, "DapBreakpointCondition", { fg = "#55FF55", bg = "none" })
  vim.api.nvim_set_hl(0, "DapLogPoint",            { fg = "#55FF55", bg = "none" })
  vim.api.nvim_set_hl(0, "DapBreakpointRejected",  { fg = "#FF8888", bg = "none" })
  vim.api.nvim_set_hl(0, "DapStopped",             { fg = "#FFFF55", bg = "none" })

  -- ✅ чтобы строка подсветки не заливала колонку
  vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#333300", default = true })

  -- ✅ И НА ВСЯКИЙ СЛУЧАЙ СНОВА ПРИБИВАЕМ SIGNCOLUMN
  vim.api.nvim_set_hl(0, "SignColumn",   { bg = "none" })
  vim.api.nvim_set_hl(0, "SignColumnNC", { bg = "none" })
end

set_dap_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = set_dap_highlights,
})

