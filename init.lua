-- =========================
--         SETS
-- =========================

-- skip deprecation warnings
vim.deprecate = function() end

vim.g.netrw_banner = 0
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
vim.opt.pumheight = 10
vim.opt.conceallevel = 0
vim.opt.fillchars = { eob = " " }
vim.opt.timeoutlen = 350
vim.opt.whichwrap:append("<,>")
vim.opt.splitbelow = true

-- Russian keyboard layout support (ЙЦУКЕН -> QWERTY) for Normal/Visual mode commands
vim.opt.langmap =
	"йцукенгшщзфывапролдячсмитьЙЦУКЕНГШЩЗФЫВАПРОЛДЯЧСМИТЬ;qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM"

-- FOLDS: automatic, by code structure (treesitter); indent fallback when no parser
vim.opt.foldenable = true
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldnestmax = 10
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    if not pcall(vim.treesitter.get_parser, args.buf) then
      vim.wo.foldmethod = "indent"
    end
  end,
})

vim.cmd("filetype plugin indent on")
vim.cmd("syntax on")
vim.g.mapleader = " "
vim.cmd("source ~/.config/nvim/macros.vim")


vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  command = "setlocal conceallevel=2",
})

-- wrap long lines, keep indent on wrapped lines
vim.opt.wrap = true
vim.opt.breakindent = true

-- Disable coc for most languages
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python", "lua" },
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
vim.api.nvim_create_user_command("QA!", "qa!", {})
vim.api.nvim_create_user_command("Qa!", "qa!", {})
vim.api.nvim_create_user_command("Wq!", "wq!", {})
vim.api.nvim_create_user_command("WQ!", "wq!", {})
vim.api.nvim_create_user_command("Qall", "qall!", {})
vim.api.nvim_create_user_command("Wqall", "wqall!", {})

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
Plug 'nvim-treesitter/nvim-treesitter', {'branch': 'master', 'do': ':TSUpdate'}
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
Plug 'gen740/SmoothCursor.nvim'
call plug#end()
]])

-- barbar (tabs) — shrink tabs as more are opened instead of just scrolling
require('barbar').setup({
  minimum_padding = 0,
  maximum_padding = 1,
  minimum_length = 0,
  maximum_length = 18,
})

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

-- Tabs navigation with leader key
vim.keymap.set("n", "bd", "<cmd>bw!<CR>", { desc = "Close buffer" })
vim.api.nvim_create_autocmd({ "BufHidden", "BufWinEnter" }, {
  callback = function()
    vim.schedule(function()
      for _, b in ipairs(vim.api.nvim_list_bufs()) do
        local name = vim.api.nvim_buf_get_name(b)
        if vim.bo[b].buflisted and name ~= "" and vim.fn.isdirectory(name) == 1
            and #vim.fn.win_findbuf(b) == 0 then
          pcall(vim.api.nvim_buf_delete, b, { force = true })
        end
      end
    end)
  end,
})
vim.keymap.set("n", "bp", ":BufferPrevious<CR>")
vim.keymap.set("n", "bn", ":BufferNext<CR>")

-- keep selection after indent/outdent so < and > can be pressed repeatedly
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- $MYVIMRC
vim.keymap.set("n", "<leader>ev", ":e $MYVIMRC<CR>")
vim.keymap.set("n", "<leader>sv", ":source $MYVIMRC<CR>")

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
vim.keymap.set("n", "fb", function() require("telescope_layouts").file_browser() end, { silent = true })
vim.keymap.set("n", "ff", function() require("telescope_layouts").find_files() end, { silent = true })
vim.keymap.set("n", "fr", function() require("telescope_layouts").buffers() end, { silent = true })
vim.keymap.set("n", "fh", function() require("telescope.builtin").help_tags() end, { silent = true })
vim.keymap.set("n", "f.", ":Telescope file_browser path=%:p:h select_buffer=true<CR>", { silent = true })
vim.keymap.set("n", "fg", ":Telescope live_grep<CR>", { silent = true })
vim.keymap.set("n", "<C-g>", function() require("telescope_layouts").live_grep() end, { silent = true })

-- wrap visual selection in inline code (`text`)
local function wrap_inline_code()
  vim.cmd("normal! \27")
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  vim.fn.cursor(end_pos[2], end_pos[3])
  vim.cmd("normal! a`")
  vim.fn.cursor(start_pos[2], start_pos[3])
  vim.cmd("normal! i`")
end
vim.keymap.set("x", "<C-y>", wrap_inline_code, { silent = true })

-- wrap word under cursor in inline code (`text`)
vim.keymap.set("n", "<C-y>", function()
  vim.cmd("normal! viw")
  wrap_inline_code()
end, { silent = true })

-- wrap visual selection in a markdown code fence (```text```)
local function wrap_code_fence()
  -- can't use '< / '> here: those marks are only set once Visual mode
  -- is actually left, but this callback runs while still inside it
  local start_line = math.min(vim.fn.line("v"), vim.fn.line("."))
  local end_line = math.max(vim.fn.line("v"), vim.fn.line("."))
  vim.cmd("normal! \27")
  vim.fn.append(end_line, "```")
  vim.fn.append(start_line - 1, "```")
end
vim.keymap.set("x", "<C-S-y>", wrap_code_fence, { silent = true })

-- wrap current line in inline code (`text`) without leaving insert mode
vim.keymap.set("i", "<C-y>", function()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  vim.api.nvim_set_current_line("`" .. line .. "`")
  vim.api.nvim_win_set_cursor(0, { row, col + 1 })
end, { silent = true })

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

-- toggle: open all folds / close all folds
vim.keymap.set("n", "zz", function()
  if vim.wo.foldlevel == 0 then
    vim.cmd("normal! zR")
  else
    vim.cmd("normal! zM")
  end
end, { silent = true })

vim.keymap.set("n", "<leader>bf", function() require("conform").format() end)

-- rebuild the vault-wide dictionary used for coc completion in markdown
vim.keymap.set("n", "<leader>vd", function() require("vault_dict").regenerate() end, { desc = "Rebuild vault dictionary" })

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

-- Snippets: coc.nvim core handles placeholder jumping for LSP-provided
-- snippets (e.g. clangd function-call params) via these two globals —
-- no coc-snippets extension needed. Do NOT also map <C-j>/<C-k> manually
-- in insert mode: that hijacks the key globally and breaks the fallback
-- when no snippet session is active.
vim.g.coc_snippet_next = "<C-j>"
vim.g.coc_snippet_prev = "<C-k>"

-- coc.nvim spawns node via a non-interactive shell, which does not source
-- .zshrc, so the nvm PATH export never applies there. Point coc directly
-- at the node binary to avoid depending on shell PATH.
vim.g.coc_node_path = vim.fn.expand("~/.nvm/versions/node/v24.19.0/bin/node")

-- ARDUINO
local arduino = require("arduino")
local esp = require("esp")

-- Arduino
vim.keymap.set("n", "<leader>am", arduino.serial)
vim.keymap.set("n", "<leader>ar", arduino.serial_restart)
vim.keymap.set("n", "<leader>as", arduino.sync)
vim.keymap.set("n", "<leader>au", arduino.upload)
vim.keymap.set("n", "<leader>ab", arduino.board)
-- Esp (ESP-IDF)
vim.keymap.set("n", "<leader>eb", esp.build)
vim.keymap.set("n", "<leader>ef", esp.flash)
vim.keymap.set("n", "<leader>eu", esp.upload)
vim.keymap.set("n", "<leader>em", esp.monitor)
vim.keymap.set("n", "<leader>ec", esp.menuconfig)
vim.keymap.set("n", "<leader>et", esp.set_target)

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

vim.keymap.set("n", "<leader>cl", ":terminal claude<CR>")
vim.keymap.set("n", "<leader>t", ":terminal<CR>")


-- LSP diagnostics (buffer-local, set on LSP attach)
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local opts = { buffer = args.buf, silent = true }
    vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, opts)
  end,
})

-- DBUI
local function db_connect()
  local dbname = vim.fn.input("Database (empty = no db): ")
  local url = "mysql://btbw:" .. (vim.env.MYSQL_PASS or "") .. "@192.168.1.120:3306/" .. dbname
  vim.b.db = url
  local label = dbname == "" and "MySQL server (no db)" or dbname
  vim.notify(" Connected to " .. label)
end

vim.keymap.set("n", "<leader>db", "<cmd>DBUIToggle<CR>", { silent = true, desc = "DBUI toggle" })
vim.keymap.set("n", "<leader>dc", db_connect, { desc = "DBUI connect" })

-- SQL buffer mappings (buffer-local, set on FileType=sql)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "sql",
  callback = function()
    local opts = { buffer = true, silent = true }

    -- execute visual selection
    vim.keymap.set("x", "<leader>e", function()
      local db = vim.b.db or vim.g.db or ""
      vim.cmd("'<,'>DB " .. db)
    end, opts)

    -- execute current line
    vim.keymap.set("n", "<leader>e", function()
      local db = vim.b.db or vim.g.db or ""
      vim.cmd(".DB " .. db)
    end, opts)

    -- execute whole file
    vim.keymap.set("n", "<leader>S", function()
      local db = vim.b.db or vim.g.db or ""
      vim.cmd("%DB " .. db)
    end, opts)
  end,
})

-- =========================
--       LUA MODULES
-- =========================

require("dbui")
require("lsp_setup")
require("autocomplete")
require("vault_dict").setup()
require("nvim-autopairs").setup({})
require("conform_setup")
require("arduino")
require("esp")

pcall(require, "theme_changer")
pcall(require, "lines")
pcall(require, "smooth_cursor")
pcall(require, "indent_guides")
pcall(require, "key_hints")
pcall(require, "nvim-dap")
pcall(require, "signcolumn")
pcall(require, "macros")
pcall(require, "render_markdown")
-- pcall(require, "mode_popup")
pcall(require, "mode_colors")

local telescope_actions = require("telescope.actions")

require("telescope").setup({
  defaults = {
    mappings = {
      i = { ["<C-g>"] = telescope_actions.send_to_qflist + telescope_actions.open_qflist },
      n = { ["<C-g>"] = telescope_actions.send_to_qflist + telescope_actions.open_qflist },
    },
  },
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
