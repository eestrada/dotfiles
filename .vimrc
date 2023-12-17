set nocompatible "Kind of pointless, but better safe than sorry.

"Don't create swapfiles by default
set uc=0

"Syntax settings
"Dark background
set background=dark
"Make sure syntax highlighting is on for supported file types.
syntax on
"Set colorscheme
colorscheme desert
"turn on special character highlighting
set list
"define what special characters look like
set listchars=trail:~,tab:>-,eol:$

"Do not ring the bell for error messages.
set noerrorbells
"Use visual bell instead of beeping.
set visualbell
"Never wrap long lines.
set nowrap
"When there is a search pattern, do no highlight all matches.
set nohlsearch
"Incremental search highlight. Useful for constructing regexes.
set incsearch
"Show line and column number.
set ruler
"Print the line number in front of each line.
set number
"Minimal number of columns to use for the line number.
set numberwidth=4
"make backspace work line most other apps
set backspace=2

"Tab Settings
"Copy indent from current line when starting a new line.
set autoindent
"Use indent rules based on current filetype.
set smartindent
"Default to using spaces when hiting <Tab> key.
set expandtab
"Number of spaces that a <Tab> counts for while editing.
set softtabstop=4
"Number of spaces that a <Tab> in the file counts for.
set tabstop=4
"same as tabstop".
set shiftwidth=0 "Number of spaces to use for each step of (auto)indent. Zero means

"At least 8 line visible buffer when moving up/down file.
set scrolloff=8
"show sign column even when empty
set signcolumn=auto
"fast update time
set updatetime=50
"visual line column(s)
set colorcolumn=80

"System friendly settings
"Using system clipboard pulled from: http://vimcasts.org/episodes/accessing-the-system-clipboard-from-vim/
"Use system clipboard for Yank and Put
set clipboard=unnamed
if has('unnamedplus')
    "Use system AND xterm clipboards for Yank and Put
    set clipboard=unnamed,unnamedplus
endif

let g:mapleader=' '

nmap <leader>e :Ex<CR>

"Delete Trailing whitespace
" Autocmd pulled from:
" http://vim.wikia.com/wiki/Remove_unwanted_spaces#Automatically_removing_all_trailing_whitespace
"autocmd BufWritePre * %s/\s\+$//e

"Search in visual mode
vnoremap <expr> // 'y/\V'.escape(@",'\').'<CR>'
