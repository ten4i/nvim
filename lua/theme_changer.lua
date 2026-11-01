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
-- kitty theme -> nvim colorscheme
-- ~/Scripts/kitty-theme writes "include themes/<name>.conf" into
-- ~/.config/kitty/current-theme.conf; the name is the key below.
-- =========================================================
local KITTY_CURRENT = vim.fn.expand("~/.config/kitty/current-theme.conf")

local function kitty_theme_name()
  local f = io.open(KITTY_CURRENT, "r")
  if not f then
    return nil
  end
  local text = f:read("*a") or ""
  f:close()
  return text:match("include%s+themes/([%w_%-]+)%.conf")
end

-- bg = vim.o.background; cmd = optional function run before :colorscheme
local function setup_mod(mod, opts)
  return function()
    local ok, m = pcall(require, mod)
    if ok and m.setup then
      m.setup(opts)
    end
  end
end

local THEMES = {
  ["mono-dark"]        = { "yin", "dark" },
  ["mono-light"]       = { "yang", "light" },
  ["gray-graphite"]    = { "koda-dark", "dark" },
  ["gray-slate"]       = { "koda-moss", "dark" },
  ["gray-silver"]      = { "koda-light", "light" },
  ["catppuccin-mocha"] = { "catppuccin-mocha", "dark" },
  ["catppuccin-latte"] = { "catppuccin-latte", "light" },
  ["dracula"]          = { "dracula", "dark" },
  ["everforest-dark"]  = { "everforest", "dark" },
  ["github-dark"]      = { "github_dark", "dark" },
  ["github-light"]     = { "github_light", "light" },
  ["gruvbox-dark"]     = { "gruvbox", "dark" },
  ["gruvbox-light"]    = { "gruvbox", "light" },
  ["kanagawa"]         = { "kanagawa", "dark" },
  ["monokai"]          = { "monokai", "dark" },
  ["nord"]             = { "nord", "dark" },
  ["one-dark"]         = { "onedark", "dark", setup_mod("onedark", { style = "dark" }) },
  ["one-light"]        = { "onedark", "light", setup_mod("onedark", { style = "light" }) },
  ["rose-pine"]        = { "rose-pine", "dark" },
  ["solarized-dark"]   = { "solarized", "dark" },
  ["solarized-light"]  = { "solarized", "light" },
  ["tokyo-night"]      = { "tokyonight-night", "dark" },
  ["tomorrow-night"]   = { "Tomorrow-Night", "dark" },
}

-- =========================================================
-- Apply theme
-- =========================================================
local function apply_theme()

  local entry = THEMES[kitty_theme_name() or ""]

  if not entry then
    -- unknown kitty theme: fall back to the GNOME dark/light switch
    if get_system_theme() == "dark" then
      entry = THEMES["mono-dark"]
    else
      entry = THEMES["mono-light"]
    end
  end

  local scheme, bg, pre = entry[1], entry[2], entry[3]

  vim.o.background = bg
  if pre then
    pre()
  end

  if not pcall(vim.cmd.colorscheme, scheme) then
    -- plugin not installed yet (:PlugInstall): keep nvim usable
    pcall(vim.cmd.colorscheme, bg == "dark" and "yin" or "yang")
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


-- follow kitty-theme changes without restarting nvim
local last_kitty = kitty_theme_name()
vim.api.nvim_create_autocmd({ "FocusGained", "VimResume" }, {
  callback = function()
    local now = kitty_theme_name()
    if now ~= last_kitty then
      last_kitty = now
      apply_theme()
    end
  end,
})
