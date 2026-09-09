-- Dictionary completion source built from every .md file in the vault,
-- so coc's suggestions aren't limited to words in the current buffer.

local M = {}

local vault_path = vim.fn.expand("~/Documents/Sync_vault")
local dict_path = vim.fn.expand("~/.cache/nvim/vault-dict.txt")

function M.regenerate()
  vim.fn.mkdir(vim.fn.fnamemodify(dict_path, ":h"), "p")
  vim.system(
    { "sh", "-c", string.format(
        "rg -o --no-filename -tmarkdown '\\w+' %s | sort -u > %s",
        vim.fn.shellescape(vault_path), vim.fn.shellescape(dict_path)
      ) },
    { text = true },
    function(obj)
      vim.schedule(function()
        if obj.code == 0 then
          vim.notify("Vault dictionary updated (" .. dict_path .. ")")
        else
          vim.notify("Vault dictionary update failed: " .. (obj.stderr or ""), vim.log.levels.ERROR)
        end
      end)
    end
  )
end

function M.setup()
  vim.opt.dictionary:append(dict_path)

  local group = vim.api.nvim_create_augroup("VaultDictionary", { clear = true })
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    pattern = vault_path .. "/**/*.md",
    callback = M.regenerate,
  })

  if vim.fn.filereadable(dict_path) == 0 then
    M.regenerate()
  end
end

return M
