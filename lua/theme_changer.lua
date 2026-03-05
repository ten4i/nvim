-- =========================================================
-- Detect GNOME system theme (light / dark)
-- =========================================================
local function get_system_theme()

  local handle = io.popen(
    "gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null"
  )

  if not handle then
    return "dark"
  end

  local result = handle:read("*a") or ""
  handle:close()

  result = result
    :lower()
    :gsub("[\n']", "")
    :gsub("%s+", "")

  if result:match("prefer%-light") then
    return "light"
  end

  return "dark"
end


-- =========================================================
-- Transparent background
-- =========================================================
local function set_transparency()

  local groups = {
    "Normal",
    "NormalNC",
    "NormalFloat",
    "FloatBorder",
    "SignColumn",
    "EndOfBuffer",
    "MsgArea",
    "FoldColumn",
    "StatusLine",
    "StatusLineNC",
    "VertSplit",
    "WinSeparator",
  }

  for _, group in ipairs(groups) do
    vim.api.nvim_set_hl(0, group, { bg = "NONE" })
  end

end


-- =========================================================
-- Cursorline + line numbers
-- =========================================================

local function set_cursor_ui()

  vim.opt.cursorline = true

  -- line numbers
  vim.api.nvim_set_hl(0, "LineNr", { fg = "#6e6e6e", bg = "NONE" })

  vim.api.nvim_set_hl(0, "CursorLineNr", {
    fg = "#e6c384",
    bg = "NONE",
    bold = true
  })

  -- editor cursor line
  vim.api.nvim_set_hl(0, "CursorLine", { bg = "#252535" })

  -- completion popup
  vim.api.nvim_set_hl(0, "Pmenu", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#252535", bold = true })

  -- floats
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#6e6e6e", bg = "NONE" })

  -- telescope selection line
  vim.api.nvim_set_hl(0, "TelescopeSelection", {
    bg = "#252535"
  })

  vim.api.nvim_set_hl(0, "TelescopeSelectionCaret", {
    fg = "#e6c384"
  })

end

-- =========================================================
-- Apply colorscheme
-- =========================================================
local function apply_theme()

  local bg = get_system_theme()

  vim.o.background = bg

  if bg == "light" then
    vim.cmd.colorscheme("kanso-pearl")
  else
    vim.cmd.colorscheme("kanso")
  end

  set_transparency()
  set_cursor_ui()

end


-- =========================================================
-- Re-apply highlights after colorscheme reload
-- =========================================================
vim.api.nvim_create_autocmd("ColorScheme", {

  callback = function()

    set_transparency()
    set_cursor_ui()

  end

})

-- =========================================================
-- Execute
-- =========================================================
apply_theme()
