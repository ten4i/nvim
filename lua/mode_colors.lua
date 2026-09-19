-- ===============================
-- Mode indication without popups:
--   * cursor color/shape per mode (guicursor)
--   * CursorLineNr color per mode
-- Colors are taken from the active colorscheme, so they follow theme changes.
-- ===============================

local M = {}

-- mode key -> highlight group of the theme whose fg is used as the mode color
-- (Diagnostic* groups are colorful even in near-monochrome themes like koda)
local sources = {
  normal  = "Normal",
  insert  = "DiagnosticOk",
  visual  = "DiagnosticHint",
  replace = "DiagnosticError",
  command = "DiagnosticWarn",
}

local cursor_groups = {
  normal  = "ModeCursorNormal",
  insert  = "ModeCursorInsert",
  visual  = "ModeCursorVisual",
  replace = "ModeCursorReplace",
  command = "ModeCursorCommand",
}

-- first char of the mode -> mode key
local mode_key = {
  n = "normal", no = "normal",
  i = "insert",
  v = "visual", V = "visual", ["\22"] = "visual",
  s = "visual", S = "visual", ["\19"] = "visual",
  R = "replace",
  c = "command",
  t = "insert",
}

local function get_hl(name)
  return vim.api.nvim_get_hl(0, { name = name, link = false })
end

-- koda has no purple, so visual matches the statusline colors (lines.lua)
local visual_purple = { light = 0x957fb8, dark = 0xaf87df }

local function color_of(key)
  if key == "visual" then
    return visual_purple[vim.o.background] or visual_purple.dark
  end
  local hl = get_hl(sources[key])
  return hl.fg or get_hl("Normal").fg or 0xffffff
end

local base_linenr -- the theme's own CursorLineNr

local function set_line_nr(key)
  if key == "normal" or not key then
    vim.api.nvim_set_hl(0, "CursorLineNr", base_linenr)
  else
    vim.api.nvim_set_hl(0, "CursorLineNr", { fg = color_of(key), bold = true })
  end
end

local function current_key()
  return mode_key[vim.fn.mode():sub(1, 1)] or "normal"
end

local function apply()
  local normal_bg = get_hl("Normal").bg
  for key, group in pairs(cursor_groups) do
    -- cursor block takes the mode color, text under it stays readable
    vim.api.nvim_set_hl(0, group, { bg = color_of(key), fg = normal_bg or 0x101010 })
  end
  base_linenr = get_hl("CursorLineNr")
  set_line_nr(current_key())
end

vim.opt.guicursor = table.concat({
  "n-c:block-" .. cursor_groups.normal,
  "v-sm:block-" .. cursor_groups.visual,
  "i-ci-ve:block-" .. cursor_groups.insert,
  "r-cr-o:block-" .. cursor_groups.replace,
  "a:blinkon0",
}, ",")

apply()

local group = vim.api.nvim_create_augroup("ModeColors", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
  group = group,
  callback = apply,
})

vim.api.nvim_create_autocmd("ModeChanged", {
  group = group,
  pattern = "*:*",
  callback = function()
    set_line_nr(mode_key[vim.v.event.new_mode:sub(1, 1)])
  end,
})

return M
