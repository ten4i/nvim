require("ibl").setup({
  enabled = false,
  indent = { char = "│" },
  scope = { enabled = false },
  exclude = {
    filetypes = { "help", "startify", "dashboard", "packer", "neogitstatus", "terminal" },
    buftypes = { "terminal", "nofile" },
  },
})
