-- =========================================================
-- LSP SETUP (works, quiet, not deprecated)
-- =========================================================

local lspconfig = require("lspconfig")
local util = require("lspconfig.util")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.lsp.handlers["window/showMessage"] = function(_, result)
  if result and result.type == vim.lsp.protocol.MessageType.Error then
    vim.notify(result.message, vim.log.levels.ERROR)
  end
end

-- =========================================================
-- Lua
-- =========================================================
lspconfig.lua_ls.setup({
  cmd = { vim.fn.expand("~/.local/share/lua-language-server/bin/lua-language-server") },
  capabilities = capabilities,
  root_dir = util.root_pattern(".git", ".luarc.json"),
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = { enable = false },
    },
  },
})


-- Python is handled by coc.nvim (coc-pyright), not the native LSP client

