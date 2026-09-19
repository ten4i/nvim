-- ===============================
-- Floating mode indicator near the cursor
-- shows NORMAL / INSERT / VISUAL (etc.) briefly
-- next to the cursor whenever the mode changes
-- ===============================

local M = {}

-- how long the popup stays visible (ms)
local HIDE_DELAY = 550

local labels = {
  n    = { text = "NORMAL",       hl = "ModePopupNormal" },
  no   = { text = "NORMAL",       hl = "ModePopupNormal" },
  niI  = { text = "NORMAL",       hl = "ModePopupNormal" },
  v    = { text = "VISUAL",       hl = "ModePopupVisual" },
  V    = { text = "VISUAL LINE",  hl = "ModePopupVisual" },
  ["\22"] = { text = "VISUAL BLOCK", hl = "ModePopupVisual" },
  s    = { text = "SELECT",       hl = "ModePopupVisual" },
  S    = { text = "SELECT LINE",  hl = "ModePopupVisual" },
  ["\19"] = { text = "SELECT BLOCK", hl = "ModePopupVisual" },
  i    = { text = "INSERT",       hl = "ModePopupInsert" },
  ic   = { text = "INSERT",       hl = "ModePopupInsert" },
  R    = { text = "REPLACE",      hl = "ModePopupReplace" },
  Rv   = { text = "REPLACE",      hl = "ModePopupReplace" },
  c    = { text = "COMMAND",      hl = "ModePopupCommand" },
  t    = { text = "TERMINAL",     hl = "ModePopupInsert" },
}

local function set_highlights()
  vim.api.nvim_set_hl(0, "ModePopupNormal",  { bg = "#3a3a3a", fg = "#ffffff", bold = true })
  vim.api.nvim_set_hl(0, "ModePopupInsert",  { bg = "#87afdf", fg = "#1c1c1c", bold = true })
  vim.api.nvim_set_hl(0, "ModePopupVisual",  { bg = "#af87df", fg = "#1c1c1c", bold = true })
  vim.api.nvim_set_hl(0, "ModePopupReplace", { bg = "#d75f5f", fg = "#1c1c1c", bold = true })
  vim.api.nvim_set_hl(0, "ModePopupCommand", { bg = "#e5c07b", fg = "#1c1c1c", bold = true })
end
set_highlights()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_highlights })

local win, buf, timer

local function close_popup()
  if timer then
    timer:stop()
    timer:close()
    timer = nil
  end
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end
  win = nil
end

local function show_popup(mode)
  local entry = labels[mode]
  if not entry then
    close_popup()
    return
  end

  if timer then
    timer:stop()
    timer:close()
    timer = nil
  end

  local text = " " .. entry.text .. " "

  if not (buf and vim.api.nvim_buf_is_valid(buf)) then
    buf = vim.api.nvim_create_buf(false, true)
  end
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { text })
  vim.bo[buf].modifiable = false

  local opts = {
    relative = "cursor",
    row = 1,
    col = 1,
    width = #text,
    height = 1,
    style = "minimal",
    border = "none",
    focusable = false,
    noautocmd = true,
    zindex = 250,
  }

  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_set_config(win, opts)
  else
    win = vim.api.nvim_open_win(buf, false, opts)
  end
  vim.wo[win].winhighlight = "Normal:" .. entry.hl
  vim.api.nvim_buf_add_highlight(buf, -1, entry.hl, 0, 0, -1)

  timer = vim.uv.new_timer()
  timer:start(HIDE_DELAY, 0, vim.schedule_wrap(close_popup))
end

local group = vim.api.nvim_create_augroup("ModePopup", { clear = true })

vim.api.nvim_create_autocmd("ModeChanged", {
  group = group,
  pattern = "*:*",
  callback = function()
    show_popup(vim.v.event.new_mode)
  end,
})

-- also close it if we leave the window/buffer entirely
vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
  group = group,
  callback = close_popup,
})

return M
