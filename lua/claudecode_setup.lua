local ok, claudecode = pcall(require, "claudecode")
if not ok then return end

claudecode.setup({
  auto_start = true,
  log_level = "warn",
  terminal_cmd = vim.fn.expand("~/.local/bin/claude"),
  focus_after_send = true,
  track_selection = true,
  terminal = {
    provider = "native",
    auto_close = true,
  },
  diff_opts = {
    auto_close_on_accept = true,
    vertical_split = true,
  },
})

vim.api.nvim_create_user_command("ClaudeH", function()
  vim.cmd("ClaudeCode")

  -- OPTION 1: vertical split (side by side) — comment out to disable
  -- vim.cmd("wincmd L")
  -- vim.cmd("vertical resize 100")

  -- OPTION 2: horizontal split (bottom) — uncomment to use instead
  vim.cmd("wincmd J")
  vim.cmd("resize 20")

end, { desc = "Open Claude split" })
