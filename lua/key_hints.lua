-- popup with available keys after a prefix (Space, g, z, ...), and search over all mappings
local ok, wk = pcall(require, "which-key")
if ok then
  wk.setup({
    delay = 300,
    preset = "helix",
  })
end

-- built-in keys (folds, ...): search by name in English or Russian
vim.keymap.set("n", "<leader>?", function()
  require("telescope_layouts").cheatsheet()
end, { desc = "Cheatsheet: built-in keys" })

-- fuzzy search over your own mappings (filter by key or description)
vim.keymap.set("n", "<leader>/", function()
  require("telescope_layouts").keymaps()
end, { desc = "Search my keymaps" })
