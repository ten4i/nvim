-- search over built-in keys and your own mappings

-- built-in keys (folds, ...): search by name in English or Russian
vim.keymap.set("n", "<leader>?", function()
  require("telescope_layouts").cheatsheet()
end, { desc = "Cheatsheet: built-in keys" })

-- fuzzy search over your own mappings (filter by key or description)
vim.keymap.set("n", "<leader>/", function()
  require("telescope_layouts").keymaps()
end, { desc = "Search my keymaps" })
