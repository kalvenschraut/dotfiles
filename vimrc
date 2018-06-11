" ------------------------------------------------------------------------------
" .vimrc
" ------------------------------------------------------------------------------

" Disable vi compatibility
set nocompatible

" Point to location of pathogen submodule (since it's not in .vim/autoload)
silent! runtime bundle/vim-pathogen/autoload/pathogen.vim
" Call pathogen plugin management
silent! execute pathogen#infect()

if has("autocmd")
	" Load files for specific filetypes
	filetype on
	filetype indent on
	filetype plugin on

	" Languages with specific tabs/space requirements
	autocmd FileType make setlocal ts=4 sts=4 sw=4 noexpandtab
	" Filetypes
	au BufRead,BufNewFile *.phar set ft=php
endif

if has("syntax")
	if &term =~ '256color'
		" disable Background Color Erase (BCE) so that color schemes
		" render properly when inside 256-color tmux and GNU screen.
		" see also http://snk.tuxfamily.org/log/vim-256color-bce.html
		set t_ut=
	endif
	" Set 256 color terminal support
	set t_Co=256
	" Enable syntax highlighting
	syntax on
	" Set dark background
	set background=dark

	" Available colorschemes
	" - onedark
	" - maui
	" - badwolf
	" - space-vim-dark
	" - solarized (see below)
	" - molokai (see below)
	colorscheme badwolf

	" Solarized color scheme
	"let g:solarized_termcolors=256
	"colorscheme solarized

	" Molokai color scheme
	"let g:molokai_original = 1
	"let g:rehash256 = 1
	"colorscheme molokai

	" Syntastic
	let g:syntastic_php_checkers = []
	let g:syntastic_javascript_checkers=['eslint']
	let g:syntastic_javascript_eslint_exe='$(npm bin)/eslint'
	let g:syntastic_cpp_check_header = 1
	let g:syntastic_cpp_config_file = '.syntastic_cpp_config'
	" let g:syntastic_debug = 3

	" Available syntastic themes
	" - onedark
	" - solarized
	" - afterglow
	" - violet (matches space-vim-dark)
	let g:airline_theme = 'onedark'
	" Enable the tab line / buffer list
	let g:airline#extensions#tabline#enabled = 1
	" Only show the file name
	let g:airline#extensions#tabline#fnamemod = ':t'
	" Enable syntastic integration
	let g:airline#extensions#syntastic#enabled = 1
	" Enable mustache abbreviations
	let g:mustache_abbreviations = 1
endif

if has("cmdline_info")
	" Show the cursor line and column number
	set ruler
	" Show partial commands in status line
	set showcmd
	" Show whether in insert or replace mode
	set showmode
endif

if has("statusline")
	" Always show status line
	set laststatus=2
endif

if has("wildmenu")
	" Show a list of possible completions
	set wildmenu
	" Tab autocomplete longest possible part of a string, then list
	set wildmode=list:longest,full
endif

if has("extra_search")
	" Highlight searches [use :noh or ctrl+l to clear]
	set hlsearch
	" Highlight dynamically as pattern is typed
	set incsearch
	" Ignore case of searches...
	set ignorecase
	" ...unless has mixed case
	set smartcase
	" Highlight matching brackets
	set showmatch
endif

" Set encoding to utf-8
set encoding=utf-8
" Reload files changed outside vim
set autoread
" Show the filename in the window titlebar
set title
" Allows buffers to be hidden if you've modified a buffer.
set hidden
" http://vim.wikia.com/wiki/Modeline_magic
set modeline
" Store lots of command history default is 20
set history=2000
" Line numbers are good
set number
" Scroll when 5 lines from top/bottom
set scrolloff=5
" Fold on markers
set foldmethod=marker
" Don't set cursor at start of line when moving
set nostartofline
" Turn on lazy redraw
set lazyredraw
" Highlight current line
set cursorline

" Show 'invisible' characters
set list
" Set characters used to indicate 'invisible' characters
set list listchars=tab:>-,trail:-,nbsp:_

" Indentation
set autoindent
set smartindent
set smarttab
set shiftwidth=4
set softtabstop=4
set tabstop=4

" Open vertical split below
set splitbelow
" Open horizontal split to the right
set splitright

" Backups, swaps and persistent undo history
set backupdir=~/.vim/backups  " where to save backups
set directory=~/.vim/swaps    " where to save swaps
set undodir=~/.vim/undo       " where to save undo history
set undofile                  " save undo's after file closes
set undolevels=1000           " how many undos
set undoreload=10000          " number of lines to save for undo

" Disable beep and flash
set noeb vb t_vb=
au GUIEnter * set vb t_vb=

" Change mapleader to ,
let mapleader=","

" Make selection again after a multi-line indent
vnoremap < <gv
vnoremap > >gv

" Toggle folds with space bar
nnoremap <Space> za

" Better page up/down
map <PageUp> <C-U>
map <PageDown> <C-D>
imap <PageUp> <C-O><C-U>
imap <PageDown> <C-O><C-D>

" Move to the next buffer
nmap <leader>l :bnext<CR>
" Move to previous buffer
nmap <leader>h :bprev<CR>
" To open a new empty buffer
nmap <leader>o :enew<cr>
" Close the current buffer and move to the previous one
nmap <leader>x :bp <BAR> bd #<CR>

" <F2> grep php files
map <F2> :vimgrep /stext/ **/*.php \| :copen

" <F8> toggles 'copy/paste mode'
map <F8> :set invpaste invnumber invlist<C-M>

" <F9> <F10> toggles vertcal line at column 80
map <F9> :set textwidth=80 colorcolumn=+1<C-M>
map <F10> :set textwidth=0 colorcolumn=0<C-M>

" <F12> forgot to open with sudo? no problem
map <F12> :w !sudo tee > /dev/null %<C-M>

" <C-l> remove highlighting after a search
nnoremap <C-l> :nohl<CR>

" Remap some common misspellings (bad habbits)
command W w
command Q q
command Wq wq
command WQ wq
