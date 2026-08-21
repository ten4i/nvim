local iron = require("iron.core")

iron.setup({
  config = {
    repl_definition = {
      python = {
        command = { "ipython" },
      },
    },

    repl_open_cmd = "belowright 20split",
  },

  highlight = {
    italic = true,
  },

  ignore_blank_lines = true,
})
