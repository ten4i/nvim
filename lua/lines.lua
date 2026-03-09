-- ===============================
-- PWD (current directory)
-- ===============================
local function pwd()
  return "󰉖 " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
end


-- ===============================
-- LSP name (detect active LSP)
-- ===============================
local function lsp_name()

  -- builtin LSP
  local clients = vim.lsp.get_active_clients({ bufnr = 0 })

  if next(clients) ~= nil then
    local names = {}
    for _, client in ipairs(clients) do
      table.insert(names, client.name)
    end
    return "  " .. table.concat(names, ", ")
  end

  -- CoC detection
  if vim.g.coc_service_initialized == 1 then
      return "⚙ CoC"
  end

  return "  No LSP"
end

-- ===============================
-- Detect light / dark
-- ===============================
local is_light = vim.o.background == "light"


-- ===============================
-- Theme palette
-- ===============================
local theme

if is_light then

  --------------------------------------------------
  -- LIGHT (kanso-pearl style)
  --------------------------------------------------

  theme = {
    normal = {
      a = { bg = "#dcd7ba", fg = "#1f1f28", gui = "bold" },
      b = { bg = "#e6e0c5", fg = "#545464" },
      c = { bg = "NONE", fg = "#545464" },
    },

    insert = {
      a = { bg = "#7e9cd8", fg = "#1f1f28", gui = "bold" }
    },

    visual = {
      a = { bg = "#957fb8", fg = "#1f1f28", gui = "bold" }
    },

    replace = {
      a = { bg = "#e46876", fg = "#1f1f28", gui = "bold" }
    },

    inactive = {
      a = { bg = "NONE", fg = "#9A9996" },
      b = { bg = "NONE", fg = "#9A9996" },
      c = { bg = "NONE", fg = "#9A9996" },
    },
  }

else

  --------------------------------------------------
  -- DARK (GOODWOLF palette)
  --------------------------------------------------

  theme = {
    normal = {
      a = { bg = "#3a3a3a", fg = "#ffffff", gui = "bold" },
      b = { bg = "#2b2b2b", fg = "#d0d0d0" },
      c = { bg = "NONE", fg = "#a8a8a8" },
    },

    insert = {
      a = { bg = "#87afdf", fg = "#1c1c1c", gui = "bold" }
    },

    visual = {
      a = { bg = "#af87df", fg = "#1c1c1c", gui = "bold" }
    },

    replace = {
      a = { bg = "#d75f5f", fg = "#1c1c1c", gui = "bold" }
    },

    inactive = {
      a = { bg = "NONE", fg = "#666666" },
      b = { bg = "NONE", fg = "#666666" },
      c = { bg = "NONE", fg = "#666666" },
    },
  }

end


-- ===============================
-- Lualine Setup
-- ===============================
require("lualine").setup({

  options = {
    icons_enabled = true,
    theme = theme,
    section_separators = { left = "", right = "" },
    component_separators = { left = "│", right = "│" },
    globalstatus = true,
  },

  sections = {

    lualine_a = { "mode" },

    lualine_b = {
      "branch",
      "diff"
    },

    lualine_c = {
      pwd,
      -- { "filename", path = 1 },
    },

    lualine_x = {
      lsp_name,
      "filetype"
    },

    lualine_y = {
      "fileformat"
    },

    lualine_z = {
      "location"
    },
  },
})

