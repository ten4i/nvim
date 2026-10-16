-- =========================================================
-- Detect GNOME system theme
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
local function transparent()

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

  for _, g in ipairs(groups) do
    local current = vim.api.nvim_get_hl(0, { name = g, link = false })
    current.bg = nil
    vim.api.nvim_set_hl(0, g, current)
  end

end


-- =========================================================
-- Darker Visual selection highlight
-- =========================================================
local function darken_visual()

  local bg = vim.o.background

  local visual_bg = (bg == "light") and "#c2c2c2" or "#3a3a3a"

  vim.api.nvim_set_hl(0, "Visual", { bg = visual_bg })

end


-- =========================================================
-- Apply theme
-- =========================================================
local function apply_theme()

  local bg = get_system_theme()

  vim.o.background = bg

  if bg == "dark" then
    vim.cmd.colorscheme("koda-dark")   -- dark theme
  else
    vim.cmd.colorscheme("koda-light")   -- light theme
  end

  transparent()
  darken_visual()

end


-- run once
apply_theme()


-- reapply transparency and Visual highlight after colorscheme
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    transparent()
    darken_visual()
  end,
})
