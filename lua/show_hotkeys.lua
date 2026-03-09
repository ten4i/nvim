local M = {}

local lines = {
  "════════════ GENERAL ════════════════════",
  "Q                : record macro",
  "<Space><Esc>     : clear search highlight",
  "sudo save        : :w !sudo tee %",
  "<leader>ev       : open $MYVIMRC",
  "<leader>sv       : restart $MYVIMRC",
  "══════════ TELESCOPE / FILES ═════════════",
  "<leader>fb       : file browser (cwd)",
  "<leader>ff       : find files",
  "<leader>fg       : live grep",
  "<leader>fr       : buffers",
  "<leader>fh       : help tags",
  "<leader>f.       : file browser (file dir)",
  "<leader>ll       : lua config files",
  "════════════ PYTHON ══════════════════════",
  "<leader>r        : run python file",
  "════════════ TRANSLATOR ══════════════════",
  "<leader>t        : traslate text",
  "════════════ BLACK FORMATER ══════════════",
  "<leader>bb        : use BLACK",
  "════════════ COMMENTS ════════════════════",
  "gcc              : toggle comment (line)",
  "gc{motion}       : toggle comment by motion",
  "gcj              : comment this + next line",
  "gcip             : comment inner paragraph",
  "Visual + gc      : comment selection",
  "════════════ DAP ══════════════════════════",
  "<F5>             : toggle breakpoint",
  "<F6>             : continue",
  "<F2>             : step over",
  "<F3>             : step into",
  "<F4>             : step out",
  "<F7>             : terminate",
  "════════════ BUFFERS ═══════════════════════",
  "t'               : next buffer",
  "tr               : previous buffer",
  "tc               : close buffer",
  "════════════ FOLDS ═════════════════════════",
  "<leader>zf       : create fold",
  "<leader>z        : toggle fold",
  "<leader>za       : toggle ALL folds",
  "<leader>zx       : delete fold",
  "════════════ ARDUINO & ESP-32 ══════════════",
  "<leader>au       : arduino upload",
  "<leader>as       : arduino sync",
  "<leader>ar       : arduino restart serial",
  "<leader>am       : arduino serial monitor",
  "<leader>eu       : esp-32 sunc/upload",
  "<leader>em       : esp-32 monitor",
  "",
 "",
}

function M.show()
  local buf = vim.api.nvim_create_buf(false, true)

  -- вставляем текст
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- считаем ширину динамически
  local width = 0
  for _, line in ipairs(lines) do
    width = math.max(width, #line)
  end
  width = width + 4

  local height = #lines

  local ui = vim.api.nvim_list_uis()[1]
  local row = math.floor((ui.height - height) / 2)
  local col = math.floor((ui.width - width) / 2)

  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  })

  -- закрытие
  vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf, silent = true })
  vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", { buffer = buf, silent = true })
end

return M

