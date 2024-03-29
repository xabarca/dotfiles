
let mapleader = " "

" Reloads config file
nnoremap <leader>s :source ~/.config/nvim/init.vim<CR>

set nobackup nowritebackup nocursorline wildmode=longest,list,full

" Display options
set showcmd
set showmode

" Turn on syntax highlighting
" syntax on

" Turn on line numbers
set number
set relativenumber

" Turn on line wrapping
set wrap

" Better searching
set ignorecase
set smartcase
set incsearch

" Better Scrolling
set scrolloff=8

" Encoding
" set encoding=utf-8

" Highlight matching search patterns but turn off after enter is pressed
set nohlsearch

" Tab settings
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent

" sets the clipboard so you can paste stuff from system clipboard 
"set clipboard^=unmamed,unnamedplus
set clipboard=unnamedplus

" syntax por PGN chess database files
au BufNewFile,BufRead *.pgn    setf pgn


" ----------------------------------------------------------
" ----------------------------------------------------------
call plug#begin('~/.config/nvim/plugged')

Plug 'sheerun/vim-polyglot'
"Plug 'arcticicestudio/nord-vim'
"Plug 'ghifarit53/tokyonight-vim'
Plug 'itchyny/lightline.vim'

call plug#end()
" ----------------------------------------------------------
" ----------------------------------------------------------


set background=dark  

if $TERM == "rxvt-unicode-256color" || $TERM == "rxvt-unicode"
    colorscheme toy-blocks 
    " colorscheme gruvbox
    let g:lightline = { 'colorscheme': 'powerlineish'}
else
    " set termguicolors

" let g:tokyonight_style = 'night' " available: night, storm
" let g:tokyonight_enable_italic = 1
    colorscheme xavi3
    let g:lightline = { 'colorscheme': 'xavi'}
end

"colorscheme toy-blocks 
let g:lightline = { 'colorscheme': 'powerlineish'}
 
" https://github.com/itchyny/lightline.vim/blob/master/colorscheme.md
 

" vmap <C-c> "*y     " Yank current selection into system clipboard
" nmap <C-c> "*Y     " Yank current line into system clipboard (if nothing is selected)
" nmap <C-v> "*p     " Paste from system clipboard



