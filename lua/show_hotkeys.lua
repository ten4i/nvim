local M = {}

local lines = {
    "════════════ GENERAL ════════════════════",
    "<leader>rp       : repeat text ",
    "Q                : record macro",
    "<Space><Esc>     : clear search highlight",
    "sudo save        : :w !sudo tee %",
    "<leader>ev       : open $MYVIMRC",
    "<leader>sv       : restart $MYVIMRC",
    "——————————— CLAUDE CODE ———————————",
    "<leader>cc       : open claude tab",
    "<leader>cf       : focus claude",
    "<leader>cb       : add current file",
    "<leader>cs       : send selection (visual)",
    "<leader>cr       : resume last session",
    "<leader>ca       : accept diff",
    "<leader>cd       : deny diff",
    "══════════ TELESCOPE / FILES ═════════════",
    "<leader>fb       : file browser (cwd)",
    "<leader>ff       : find files",
    "<leader>fg       : live grep",
    "<leader>fr       : buffers",
    "<leader>fh       : help tags",
    "<leader>f.       : file browser (file dir)",
    "<leader>ll       : lua config files",
    "<ctrl>q          : grep many files window",
    "══════════ MOVE LINES ═════════════",
    "<S-Down>         : move line/block down",
    "<S-Up>           : move line/block up",
    "════════════ PYTHON ══════════════════════",
    "<leader>r        : run python file",
    "normal<leader>pp : start ipython terminal",
    "visual<leader>pp : pass selection ipython",
    "<leader>lp       : run ipython line",
    "<leader>fp       : run ipython file",
    "════════════ TRANSLATOR ══════════════════",
    "<leader>t        : traslate text",
    "════════════ BLACK FORMATER ══════════════",
    "<leader>bf       : use python formater",
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
    "<S-right>               : next buffer",
    "<S-left>         : previous buffer",
    "<C-w>               : close buffer",
    "════════════ FOLDS ═════════════════════════",
    "zf               : create fold",
    "zz               : toggle folds",
    "zx               : delete fold",
    "════════════ ARDUINO & ESP-32 ══════════════",
    "<C-j>            : next snippet",
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

