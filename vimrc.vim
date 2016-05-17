set nocompatible "Kind of pointless, but better safe than sorry.

colorscheme koehler "Set default color scheme for gvim.

"Don't create swapfiles by default
set uc=0

"Syntax settings
syntax on "Make sure syntax highlighting is on for supported file types.
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
set expandtab "Use the appropriate number of spaces to insert a	<Tab>.
set softtabstop=4 "Number of spaces that a <Tab> counts for while editing.
set tabstop=4 "Number of spaces that a <Tab> in the file counts for.

