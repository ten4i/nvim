" skipped eror texts 
lua << EOF
vim.deprecate = function() end
EOF

" sets, mapleader, filetypes
let g:netrw_banner = 0
" set guicursor=a:block
set spelllang=ru
" set cursorline
set mouse=a
set encoding=utf-8
" set relativenumber
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
Plug 'Shatur/neovim-ayu'
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
call plug#end()

" HOTKEYS

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
" buffers (barbar)
nnoremap t' :BufferNext<CR>
nnoremap tr :BufferPrevious<CR>
nnoremap tc :BufferClose<CR>
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


" =========================
" STARTUP LUA
" =========================

lua << EOF
require("lsp_setup")
require('nvim-autopairs').setup({})
require("conform_setup")

pcall(require, "macros")
pcall(require, "lines")
pcall(require, "nvim-dap")
pcall(require, "signcolumn")
pcall(require, "autocomplete")
pcall(require, "theme_changer")
pcall(require, "show_hotkeys")
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
