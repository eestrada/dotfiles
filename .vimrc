set nocompatible "Kind of pointless, but better safe than sorry.

"Don't create swapfiles by default
set uc=0

"Syntax settings
let base16colorspace=256  " Access colors present in 256 colorspace
syntax on "Make sure syntax highlighting is on for supported file types.
set background=dark
colorscheme base16-monokai
set list "turn on special character highlighting
set listchars=trail:·,tab:»-,eol:¬ "define what special characters look like

set autoindent "Copy indent from current line when starting a new line.
set shiftwidth=4 "Number of spaces to use for each step of (auto)indent.
set noerrorbells "Do not ring the bell for error messages.
set visualbell "Use visual bell instead of beeping.
"set wrap "Lines longer than the width of the window will wrap.
set nowrap "Never wrap long lines.
set hlsearch "When there is a search pattern, highlight all matches.
set ruler "Show line and column number.
set number "Print the line number in front of each line.
set numberwidth=4 "Minimal number of columns to use for the line number.
set backspace=2 "make backspace work line most other apps

"Tab Settings
"set expandtab "Use the appropriate number of spaces to insert a	<Tab>.
set noexpandtab "Messes up Makefiles and stuff. Just hit spacebar a few extra times.
set softtabstop=4 "Number of spaces that a <Tab> counts for while editing.
set tabstop=4 "Number of spaces that a <Tab> in the file counts for.

"System friendly settings
"Using system clipboard pulled from: http://vimcasts.org/episodes/accessing-the-system-clipboard-from-vim/
"Use system clipboard for Yank and Put
set clipboard=unnamed
if has('unnamedplus')
    "Use system AND xterm clipboards for Yank and Put
    set clipboard=unnamed,unnamedplus
endif

"Delete Trailing whitespace
" Autocmd pulled from:
" http://vim.wikia.com/wiki/Remove_unwanted_spaces#Automatically_removing_all_trailing_whitespace
"autocmd BufWritePre * %s/\s\+$//e

"Search in visual mode
vnoremap <expr> // 'y/\V'.escape(@",'\').'<CR>'
