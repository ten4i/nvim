" skipped eror texts 
lua << EOF
vim.deprecate = function() end
EOF
" sets, mapleader, filetypes
let g:netrw_banner = 0
set guicursor=a:block
set spelllang=ru
set cursorline
set mouse=a
set encoding=utf-8
set relativenumber
set number
set numberwidth=1
set noswapfile
set scrolloff=7
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set autoindent
set fileformat=unix
set ignorecase
set smartcase
set incsearch
set hlsearch
set signcolumn=yes
set fillchars=eob:\ 
set timeoutlen=500


" FOLDS — MANUAL + SAVE
set foldenable
set foldmethod=manual
set foldlevel=99
set foldlevelstart=99
set foldnestmax=10
" save FOLDS only
set viewoptions=folds

filetype on
filetype plugin on
filetype indent on
syntax on
let mapleader = " "
source ~/.config/nvim/macros.vim

" Disable coc for most languages
autocmd FileType python let b:coc_enabled = 0
autocmd FileType lua let b:coc_enabled = 0
autocmd FileType sh let b:coc_enabled = 0

" Enable coc for embedded / arduino / C family
autocmd FileType c let b:coc_enabled = 1
autocmd FileType cpp let b:coc_enabled = 1
autocmd FileType arduino let b:coc_enabled = 1
autocmd FileType ino let b:coc_enabled = 1

" Case-insensitive commands for save/quit
command! W  w
command! Q  q
command! Wq wq
command! WQ wq
command! Wqa wqa
command! WQa wqa
command! Qa qa
command! QA qa


" Dir for views
set viewdir=~/.local/state/nvim/view//
silent! call mkdir(&viewdir, 'p')

augroup PersistFolds
  autocmd!
  " сохранить фолды при выходе из окна
  autocmd BufWinLeave * silent! mkview
  " загрузить фолды при входе
  autocmd BufWinEnter * silent! loadview
augroup END


" MACROS
function! SaveMacro()
  let r = nr2char(getchar())
  if empty(eval('@' . r))
    echo "Register @" . r . " is empty"
    return
  endif
  execute "put = 'let @" . r . " = ' . string(@" . r . ")"
endfunction

" =========================
" INDENTLINE
let g:indentLine_char = '│'
let g:indentLine_fileTypeExclude = ['help', 'startify', 'dashboard', 'packer', 'neogitstatus']

" =========================
" PLUGINS
" =========================

call plug#begin('~/.config/nvim/plugged')
Plug 'nvim-lualine/lualine.nvim'
Plug 'romgrk/barbar.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope-file-browser.nvim'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'ryanoasis/vim-devicons'
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'L3MON4D3/luaSnip'
Plug 'tpope/vim-commentary'
Plug 'mfussenegger/nvim-dap'
Plug 'rcarriga/nvim-dap-ui'
Plug 'mfussenegger/nvim-dap-python'
Plug 'nvim-neotest/nvim-nio'
Plug 'tpope/vim-fugitive'
Plug 'lewis6991/gitsigns.nvim'
Plug 'plasticboy/vim-markdown'
Plug 'windwp/nvim-autopairs'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'romgrk/barbar.nvim'
Plug 'Yggdroot/indentLine'
Plug 'stevearc/conform.nvim'
Plug 'webhooked/kanso.nvim'
Plug 'sjl/badwolf'
Plug 'yankcrime/direwolf'
Plug 'pgdouyon/vim-yin-yang'
Plug 'sphamba/smear-cursor.nvim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'stevearc/vim-arduino'
call plug#end()


" =========================
" HOTKEYS
" =========================


" $MYVIMRC
nnoremap <leader>ev :e $MYVIMRC<CR>
nnoremap <leader>sv :source $MYVIMRC<CR>

" splits
nnoremap <silent> <C-h> <C-w>h
nnoremap <silent> <C-j> <C-w>j
nnoremap <silent> <C-k> <C-w>k
nnoremap <silent> <C-l> <C-w>l
" Resize splits with Alt + hjkl
nnoremap <M-h> :vertical resize -2<CR>
nnoremap <M-l> :vertical resize +2<CR>
nnoremap <M-j> :resize +2<CR>
nnoremap <M-k> :resize -2<CR>
" rotation
nnoremap <leader>w <C-w> 
" remap q
nnoremap Q q
nnoremap q <nop>
" python
nnoremap <leader>r :!python3 %<CR>
" cancel highlight
nnoremap <space><esc> :nohlsearch<CR>
" debug (DAP)
nnoremap <F5> :lua require'dap'.toggle_breakpoint()<CR>
nnoremap <F6> :lua require'dap'.continue()<CR>
nnoremap <F2> :lua require'dap'.step_over()<CR>
nnoremap <F3> :lua require'dap'.step_into()<CR>
nnoremap <F4> :lua require'dap'.step_out()<CR>
nnoremap <F7> :lua require'dap'.terminate()<CR>

" Telescope smart layout
nnoremap <silent> <leader>fb :lua require("telescope_layouts").file_browser()<CR>
nnoremap <silent> <leader>ff :lua require("telescope_layouts").find_files()<CR>
nnoremap <silent> <leader>fr :lua require("telescope_layouts").buffers()<CR>
nnoremap <silent> <leader>fh :lua require('telescope.builtin').help_tags()<CR>
nnoremap <silent> <leader>f. :Telescope file_browser path=%:p:h select_buffer=true<CR>
nnoremap <silent> <leader>fg :Telescope live_grep<CR>
" barbar buffers



" clipboard
vmap <C-c> "+y<Esc>i
vmap <C-x> "+d<Esc>i
imap <C-v> <Esc>"+pi
imap <C-z> <Esc>ui
inoremap <C-a> <Esc>ggVG
vnoremap <C-a> <Esc>ggVG
xnoremap <C-a> <Esc>ggVG
tnoremap <C-a> <Esc>ggVG
" yank / paste system
noremap <Leader>y "+y
noremap <Leader>p "+p
noremap <Leader>Y "*y
noremap <Leader>P "*p

" lua from telescope
nnoremap <leader>ll :lua require("telescope.builtin").find_files({
      \ cwd = vim.fn.stdpath("config") .. "/lua",
      \ prompt_title = "Lua config",
      \ })<CR>
" folds creating
nnoremap <silent> <leader>zf zf
vnoremap <silent> <leader>zf zf
nnoremap <silent> <leader>z za
nnoremap <silent> <leader>Z :if &foldlevel == 0 \| execute "normal! zR" \| else \| execute "normal! zM" \| endif<CR>
nnoremap <silent> <leader>zx :silent! normal! zd<CR>
"showhotkeys
nnoremap <leader>h :lua require("show_hotkeys").show()<CR>
"translate
nnoremap <leader>t :lua require("translator").translate_word()<CR>
vnoremap <leader>t :lua require("translator").translate_visual()<CR>
nnoremap <leader>bb :lua require("conform").format()<CR>

" move line up
nnoremap <S-Up> :m .-2<CR>==
" move line down
nnoremap <S-Down> :m .+1<CR>==
" move selected block up
vnoremap <S-Up> :m '<-2<CR>gv=gv
" move selected block down
vnoremap <S-Down> :m '>+1<CR>gv=gv
"terminal 
tnoremap <S-Right> <C-\><C-n>:BufferNext<CR>
tnoremap <S-Left> <C-\><C-n>:BufferPrevious<CR>
tnoremap <C-q> :BufferClose!<CR>


" barbar buffers
map <S-Right> :BufferNext<CR>
map <S-Left> :BufferPrevious<CR>
map <C-q> :BufferClose!<CR>


" ARDUINO
" CoC completion confirm
" ENTER confirms selection
inoremap <expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"
" TAB → next suggestion
inoremap <expr> <Tab> coc#pum#visible() ? coc#pum#next(1) : "\<Tab>"
" SHIFT+TAB → previous suggestion
inoremap <expr> <S-Tab> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" -------------------------------------------------
" Open IPython terminal
" -------------------------------------------------
autocmd TermOpen * startinsert
autocmd TermOpen * let g:ipython_job_id = b:terminal_job_id

tnoremap <Esc> <C-\><C-n>
command! Termpy terminal ipython
vnoremap <leader>rr <Esc>:lua require("ipython_runner").send_selection()<CR>
nnoremap <leader>rl :lua require("ipython_runner").run_line()<CR>
nnoremap <leader>rf :lua require("ipython_runner").run_file()<CR>

lua << EOF
local arduino = require("arduino")
local esp32 = require("esp32")

-- Arduino
vim.keymap.set("n","<leader>am", arduino.serial)
vim.keymap.set("n","<leader>ar", arduino.serial_restart)
vim.keymap.set("n","<leader>as", arduino.sync)
vim.keymap.set("n","<leader>au", arduino.upload)
-- ESP32
vim.keymap.set("n","<leader>eu", esp32.upload)
vim.keymap.set("n","<leader>em", esp32.monitor)
EOF

" =========================
" STARTUP LUA
" =========================

lua << EOF
require("lsp_setup")
require('nvim-autopairs').setup({})
require("conform_setup")

pcall(require, "theme_changer")
pcall(require, "lines")
pcall(require, "nvim-dap")
pcall(require, "signcolumn")
pcall(require, "autocomplete")
pcall(require, "show_hotkeys")
pcall(require, "macros")
pcall(require, "translator")

require("telescope").setup({
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
EOF


augroup arduino_cpp
  autocmd!
  autocmd FileType arduino setlocal filetype=cpp
augroup END
