-- =========================
--         SETS
-- =========================

-- skip deprecation warnings
vim.deprecate = function() end

vim.g.netrw_banner = 0
-- vim.opt.guicursor = "a:block-blinkon0"
vim.opt.spelllang = "ru"
vim.opt.cursorline = true
vim.opt.mouse = "a"
vim.opt.encoding = "utf-8"
-- vim.opt.relativenumber = true
-- vim.opt.number = true
-- vim.opt.numberwidth = 1
vim.opt.swapfile = false
vim.opt.scrolloff = 7
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.fileformat = "unix"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.signcolumn = "yes"
vim.opt.conceallevel = 0
vim.opt.fillchars = { eob = " " }
vim.opt.timeoutlen = 350
vim.opt.whichwrap:append("<,>")
vim.opt.splitbelow = true

-- FOLDS — MANUAL + SAVE
vim.opt.foldenable = true
vim.opt.foldmethod = "manual"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldnestmax = 10
-- save FOLDS only
vim.opt.viewoptions = "folds"

vim.cmd("filetype plugin indent on")
vim.cmd("syntax on")
vim.g.mapleader = " "
vim.cmd("source ~/.config/nvim/macros.vim")

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  command = "setlocal conceallevel=2",
})

-- Disable coc for most languages
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python", "lua", "sh" },
  callback = function() vim.b.coc_enabled = 0 end,
})

-- Enable coc for embedded / arduino / C family
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "arduino", "ino" },
  callback = function() vim.b.coc_enabled = 1 end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function() vim.b.coc_snippet_disable = 1 end,
})

-- Case-insensitive commands for save/quit
vim.api.nvim_create_user_command("W", "w", {})
vim.api.nvim_create_user_command("Q", "qa!", {})
vim.api.nvim_create_user_command("Wq", "wq", {})
vim.api.nvim_create_user_command("WQ", "wq", {})
vim.api.nvim_create_user_command("Wqa", "wqa", {})
vim.api.nvim_create_user_command("WQa", "wqa", {})
vim.api.nvim_create_user_command("Qa", "qa", {})
vim.api.nvim_create_user_command("QA", "qa", {})

-- Dir for views
vim.opt.viewdir = vim.fn.expand("~/.local/state/nvim/view//")
pcall(vim.fn.mkdir, vim.o.viewdir, "p")

local persist_folds = vim.api.nvim_create_augroup("PersistFolds", { clear = true })
-- сохранить фолды при выходе из окна
vim.api.nvim_create_autocmd("BufWinLeave", {
  group = persist_folds,
  pattern = "*",
  callback = function() pcall(vim.cmd, "mkview") end,
})
-- загрузить фолды при входе
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = persist_folds,
  pattern = "*",
  callback = function() pcall(vim.cmd, "loadview") end,
})

-- MACROS
function _G.SaveMacro()
  local r = vim.fn.nr2char(vim.fn.getchar())
  if vim.fn.getreg(r) == "" then
    print("Register @" .. r .. " is empty")
    return
  end
  vim.cmd("put = 'let @" .. r .. " = ' . string(@" .. r .. ")")
end

-- =========================
--         PLUGINS
-- =========================

vim.cmd([[
call plug#begin('~/.config/nvim/plugged')
Plug 'nvim-lualine/lualine.nvim'
Plug 'romgrk/barbar.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope-file-browser.nvim'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'ryanoasis/vim-devicons'
Plug 'neovim/nvim-lspconfig'
Plug 'L3MON4D3/luaSnip'
Plug 'tpope/vim-commentary'
Plug 'mfussenegger/nvim-dap'
Plug 'rcarriga/nvim-dap-ui'
Plug 'mfussenegger/nvim-dap-python'
Plug 'nvim-neotest/nvim-nio'
Plug 'lewis6991/gitsigns.nvim'
Plug 'MeanderingProgrammer/render-markdown.nvim'
Plug 'windwp/nvim-autopairs'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'romgrk/barbar.nvim'
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'stevearc/conform.nvim'
Plug 'webhooked/kanso.nvim'
Plug 'oskarnurm/koda.nvim'
Plug 'sjl/badwolf'
Plug 'yankcrime/direwolf'
Plug 'pgdouyon/vim-yin-yang'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'stevearc/vim-arduino'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'tpope/vim-dadbod'
Plug 'kristijanhusak/vim-dadbod-ui'
Plug 'kristijanhusak/vim-dadbod-completion'
Plug 'christoomey/vim-tmux-navigator'
Plug 'oskarnurm/koda.nvim.git'
call plug#end()
]])

-- =========================
--    HOTKEYS & lua MODULES
-- =========================

-- navigation
vim.keymap.set("", "<S-Left>", ":BufferPrev<CR>", { silent = true })
vim.keymap.set("", "<S-Right>", ":BufferNext<CR>", { silent = true })
vim.keymap.set("i", "<S-Left>", "<Esc>:BufferPrev<CR>", { silent = true })
vim.keymap.set("i", "<S-Right>", "<Esc>:BufferNext<CR>", { silent = true })
vim.keymap.set("t", "<S-Left>", [[<C-\><C-n>:BufferPrev<CR>]], { silent = true })
vim.keymap.set("t", "<S-Right>", [[<C-\><C-n>:BufferNext<CR>]], { silent = true })
vim.keymap.set("n", "<S-Down>", "8j")
vim.keymap.set("n", "<S-Up>", "8k")
vim.keymap.set("v", "<S-Down>", "8j")
vim.keymap.set("v", "<S-Up>", "8k")

-- keep selection after indent/outdent so < and > can be pressed repeatedly
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- $MYVIMRC
vim.keymap.set("n", "<leader>ev", ":e $MYVIMRC<CR>")
vim.keymap.set("n", "<leader>sv", ":source $MYVIMRC<CR>")

-- splits
vim.g.tmux_navigator_no_mappings = 1
vim.keymap.set("n", "<A-Left>", ":<C-U>TmuxNavigateLeft<CR>", { silent = true })
vim.keymap.set("n", "<A-Down>", ":<C-U>TmuxNavigateDown<CR>", { silent = true })
vim.keymap.set("n", "<A-Up>", ":<C-U>TmuxNavigateUp<CR>", { silent = true })
vim.keymap.set("n", "<A-Right>", ":<C-U>TmuxNavigateRight<CR>", { silent = true })

-- rotation
vim.keymap.set("n", "<leader>w", "<C-w>")
-- remap q
vim.keymap.set("n", "Q", "q")
vim.keymap.set("n", "q", "<nop>")
-- python
vim.keymap.set("n", "<leader>r", ":!python3 %<CR>")
-- cancel highlight
vim.keymap.set("n", "<leader>h", ":nohlsearch<CR>")
-- debug (DAP)
vim.keymap.set("n", "<F5>", function() require("dap").toggle_breakpoint() end)
vim.keymap.set("n", "<F6>", function() require("dap").continue() end)
vim.keymap.set("n", "<F2>", function() require("dap").step_over() end)
vim.keymap.set("n", "<F3>", function() require("dap").step_into() end)
vim.keymap.set("n", "<F4>", function() require("dap").step_out() end)
vim.keymap.set("n", "<F7>", function() require("dap").terminate() end)

-- Telescope smart layout
vim.keymap.set("n", "<leader>fb", function() require("telescope_layouts").file_browser() end, { silent = true })
vim.keymap.set("n", "<leader>ff", function() require("telescope_layouts").find_files() end, { silent = true })
vim.keymap.set("n", "<leader>fr", function() require("telescope_layouts").buffers() end, { silent = true })
vim.keymap.set("n", "<leader>fh", function() require("telescope.builtin").help_tags() end, { silent = true })
vim.keymap.set("n", "<leader>f.", ":Telescope file_browser path=%:p:h select_buffer=true<CR>", { silent = true })
vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>", { silent = true })

-- wrap visual selection in a markdown code fence
local function wrap_code_fence()
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")
  vim.fn.append(end_line, "```")
  vim.fn.append(start_line - 1, "```")
end
vim.keymap.set("x", "<C-y>", wrap_code_fence, { silent = true })

-- usual clipboard's sets
vim.keymap.set("v", "<C-c>", '"+y<Esc>i')
vim.keymap.set("v", "<C-x>", '"+d<Esc>i')
vim.keymap.set("i", "<C-z>", "<Esc>ui")
-- yank / paste system
vim.keymap.set("", "<leader>y", '"+y')
vim.keymap.set("", "<leader>p", '"+p')
vim.keymap.set("", "<leader>Y", '"*y')
vim.keymap.set("", "<leader>P", '"*p')
vim.keymap.set("i", "<C-h>", "<C-w>")

-- lua from telescope
vim.keymap.set("n", "<leader>ll", function()
  require("telescope.builtin").find_files({
    cwd = vim.fn.stdpath("config") .. "/lua",
    prompt_title = "Lua config",
  })
end)

-- folds creating
vim.keymap.set("n", "zz", function()
  if vim.wo.foldlevel == 0 then
    vim.cmd("normal! zR")
  else
    vim.cmd("normal! zM")
  end
end, { silent = true })
vim.keymap.set("n", "zx", ":silent! normal! zd<CR>", { silent = true })

vim.keymap.set("n", "<leader>bf", function() require("conform").format() end)

-- repeat
vim.keymap.set("n", "<leader>rp", ":put =repeat('', )<Left><Left><Left><Left>")

-- =========================
-- CoC completion (clean)
-- =========================

local function check_backspace()
  local col = vim.fn.col(".") - 1
  return col == 0 or vim.fn.getline("."):sub(col, col):match("%s") ~= nil
end

-- TAB → confirm selection OR insert tab OR trigger completion
vim.keymap.set("i", "<Tab>", function()
  if vim.fn["coc#pum#visible"]() == 1 then
    return vim.fn["coc#pum#confirm"]()
  elseif vim.fn.pumvisible() == 1 then
    return "<C-n>"
  elseif check_backspace() then
    return "<Tab>"
  else
    return vim.fn["coc#refresh"]()
  end
end, { silent = true, expr = true })

-- SHIFT+TAB → previous item
vim.keymap.set("i", "<S-Tab>", function()
  if vim.fn["coc#pum#visible"]() == 1 then
    return vim.fn["coc#pum#prev"](1)
  elseif vim.fn.pumvisible() == 1 then
    return "<C-p>"
  else
    return "<C-h>"
  end
end, { expr = true })

-- ENTER → confirm selection
vim.keymap.set("i", "<CR>", function()
  if vim.fn["coc#pum#visible"]() == 1 then
    return vim.fn["coc#pum#confirm"]()
  elseif vim.fn.pumvisible() == 1 then
    return "<C-y>"
  else
    return "<CR>"
  end
end, { silent = true, expr = true })

-- Arrow navigation (optional but nice)
vim.keymap.set("i", "<Down>", function()
  if vim.fn["coc#pum#visible"]() == 1 then
    return vim.fn["coc#pum#next"](1)
  elseif vim.fn.pumvisible() == 1 then
    return "<C-n>"
  else
    return "<Down>"
  end
end, { expr = true })

vim.keymap.set("i", "<Up>", function()
  if vim.fn["coc#pum#visible"]() == 1 then
    return vim.fn["coc#pum#prev"](1)
  elseif vim.fn.pumvisible() == 1 then
    return "<C-p>"
  else
    return "<Up>"
  end
end, { expr = true })

-- Snippets (you already use C-j / C-k — keep it)
vim.keymap.set("i", "<C-j>", "<Plug>(coc-snippets-expand-jump)", { remap = true })
vim.keymap.set("v", "<C-j>", "<Plug>(coc-snippets-select)", { remap = true })
vim.g.coc_snippet_next = "<C-j>"
vim.g.coc_snippet_prev = "<C-k>"

-- coc.nvim spawns node via a non-interactive shell, which does not source
-- .zshrc, so the nvm PATH export never applies there. Point coc directly
-- at the node binary to avoid depending on shell PATH.
vim.g.coc_node_path = vim.fn.expand("~/.nvm/versions/node/v24.19.0/bin/node")

-- closing buffer
vim.keymap.set("n", "<C-l>", ":bd!<CR>")
vim.keymap.set("t", "<C-l>", ":bd!<CR>")

-- ARDUINO
local arduino = require("arduino")
local esp = require("esp")

-- Arduino
vim.keymap.set("n", "<leader>am", arduino.serial)
vim.keymap.set("n", "<leader>ar", arduino.serial_restart)
vim.keymap.set("n", "<leader>as", arduino.sync)
vim.keymap.set("n", "<leader>au", arduino.upload)
-- esp
vim.keymap.set("n", "<leader>eu", esp.upload)
vim.keymap.set("n", "<leader>em", esp.monitor)

-- -------------------------------------------------
-- Open IPython terminal
-- -------------------------------------------------
--  ~/.ipython/profile_default/ipython_config.py

vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  command = "startinsert",
})
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = function() vim.g.ipython_job_id = vim.b.terminal_job_id end,
})

vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]])
vim.keymap.set("t", ":q", "exit")

vim.api.nvim_create_user_command("Termpy", "terminal ipython", {})
vim.keymap.set("", "<leader>pp", ":Termpy<CR>")
vim.keymap.set("v", "<leader>pp", function() require("ipython_runner").send_selection() end)
vim.keymap.set("n", "<leader>lp", function() require("ipython_runner").run_line() end)
vim.keymap.set("n", "<leader>fp", function() require("ipython_runner").run_file() end)

-- CLAUDE CODE
vim.keymap.set("n", "<leader>cc", ":ClaudeH<CR>")
vim.keymap.set("n", "<leader>cf", ":ClaudeCodeFocus<CR>")
vim.keymap.set("n", "<leader>cb", ":ClaudeCodeAdd %<CR>")
vim.keymap.set("v", "<leader>cs", ":ClaudeCodeSend<CR>")
vim.keymap.set("n", "<leader>cr", ":ClaudeCode --resume<CR>")
vim.keymap.set("n", "<leader>ca", ":ClaudeCodeDiffAccept<CR>")
vim.keymap.set("n", "<leader>cd", ":ClaudeCodeDiffDeny<CR>")

vim.keymap.set("n", "<leader>cl", ":terminal claude<CR>")
vim.keymap.set("n", "<leader>t", ":terminal<CR>")

-- =========================
--       LUA MODULES
-- =========================

require("dbui")
require("lsp_setup")
require("autocomplete")
require("nvim-autopairs").setup({})
require("conform_setup")
require("claudecode_setup")
require("arduino")
require("esp")

pcall(require, "theme_changer")
pcall(require, "lines")
pcall(require, "indent_guides")
pcall(require, "nvim-dap")
pcall(require, "signcolumn")
pcall(require, "macros")
pcall(require, "render_markdown")

require("telescope").setup({
  pickers = {
    find_files = {
      hidden = true,
      no_ignore = false,
    },
  },
  extensions = {
    file_browser = {
      previewer = true,
      hidden = true,
      grouped = true,
      git_status = false,
    },
  },
})

require("telescope").load_extension("file_browser")

-- vim.cmd.colorscheme("koda-glade")
