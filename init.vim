set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set relativenumber 
set number
set nobackup 
set noswapfile 
set tabstop=8
set shiftwidth=4
set nohlsearch
set incsearch
set syntax
set scrolloff=8
set encoding=utf-8
set mouse=a
let mapleader=' '
call plug#begin() 

	Plug 'vim-airline/vim-airline'	
	Plug 'flazz/vim-colorschemes'
	Plug 'vim-airline/vim-airline-themes'
	Plug 'ap/vim-css-color'
	Plug 'scrooloose/nerdcommenter'
	Plug 'sudar/vim-arduino-syntax'
        Plug 'nvim-telescope/telescope.nvim'
        Plug 'neoclide/coc.nvim'
        Plug 'marcelbeumer/spacedust.vim'


call plug#end()

colorscheme spacedust

" Ctrl + Backspace to delete the previous word
noremap! <C-BS> <C-w>
noremap! <C-h> <C-w>

nnoremap <leader>h :vertical resize -5<CR>
nnoremap <leader>l :vertical resize +5<CR>
nnoremap <leader>s :source %<CR>
