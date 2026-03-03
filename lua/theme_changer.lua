-- =========================================================
-- 🌗 Detect GNOME system theme (light / dark)
-- =========================================================
local function get_system_theme()
  local handle = io.popen("gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null")
  if not handle then
    return "dark"
  end

  local result = handle:read("*a") or ""
  handle:close()

  result = result:lower():gsub("[\n']", ""):gsub("%s+", "")

  if result:match("prefer%-light") then
    return "light"
  end
  return "dark"
end

-- =========================================================
-- 🫥 Transparent background
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
    "LineNr",
    "CursorLineNr",
    "StatusLine",
    "StatusLineNC",
    "VertSplit",
    "WinSeparator",
  }

  for _, group in ipairs(groups) do
    vim.api.nvim_set_hl(0, group, { bg = "NONE" })
  end
  -- sometimes needed for floats
  vim.api.nvim_set_hl(0, "Pmenu", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "PmenuSel", {
  bg = "#E2E1DF", -- subtle highlight
  bold = true,
})
end

-- =========================================================
-- 🎨 Apply colorscheme + transparency
-- =========================================================
local function apply_theme()
  local bg = get_system_theme()
  vim.o.background = bg

  if bg == "light" then
    vim.cmd.colorscheme("yang")
  else
    vim.cmd.colorscheme("yin")
  end

  set_transparency()
end

-- =========================================================
-- ✅ Make it stick (themes re-apply highlights)
-- =========================================================
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    set_transparency()
  end,
})

-- =========================================================
-- 🚀 Execute
-- =========================================================
apply_theme()
