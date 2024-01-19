" Kind of pointless, but better safe than sorry.
set nocompatible

" [[ Global Variables ]]

" Set <space> as the leader key
" See `:help mapleader`
"  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
let g:mapleader=' '
let g:maplocalleader=' '

" Neovim will use `xdg-open` by default. WSL2 will set this to something that
" can be opened in Windows directly. No special config is necessary here, just
" make sure to install xdg-open and neovim will do the right thing.
" https://superuser.com/a/1687625/474473
"
" If things are really bad and that doesn't work, set g:netrw_browsex_viewer,
" like mentioned below. You can use `sensible-browser` on debian based
" systems. Or you can install and use `wslview`. However, all of these things
" should not be necessary if `xdg-open` is available.
" * https://neovim.io/doc/user/pi_netrw.html#netrw_filehandler

" [[ Utility variables ]]
let s:data_dir = has('nvim') ? stdpath('data') : '~/.vim'
let s:state_dir = has('nvim') ? stdpath('state') : '~/.vim/state'
let s:config_dir = has('nvim') ? stdpath('config') : '~/.vim'

" [[ Setting options ]]
" Don't create swapfiles by default
set updatecount=0

" Enable mouse mode
set mouse=a

" Save undo history
set undofile
if !has('nvim')
  " The Vim default is the current directory `.` This ends up causing lots of
  " junk being scattered around. Use data dir or /tmp
  let s:undo_dir = s:state_dir . '/undo'
  let &undodir=s:undo_dir
endif
set undodir+=~/tmp/

" Case-insensitive searching UNLESS \C or capital in search
set ignorecase
set smartcase

" Set completeopt to have a better completion experience
set completeopt=menu,menuone,noselect

" Syntax settings
" NOTE: make sure current terminal supports this
" set termguicolors

" Dark background
set background=dark
" Make sure syntax highlighting is on for supported file types.
syntax enable
" Set colorscheme
colorscheme desert

" turn on special character highlighting
set list
" define what special characters look like
set listchars=trail:~,tab:>-

" Do not ring the bell for error messages.
set noerrorbells

" Use visual bell instead of beeping.
set visualbell

" Never wrap long lines.
set nowrap

" When there is a search pattern, do no highlight all matches.
set nohlsearch
" Incremental search highlight. Useful for constructing regexes.
set incsearch

" Show line and column number.
set ruler
" Print the line number in front of each line.
set number
" Minimal number of columns to use for the line number.
set numberwidth=4
" make backspace work line most other apps
set backspace=2

" Tab Settings
" Copy indent from current line when starting a new line.
set autoindent
" Use indent rules based on current filetype.
set smartindent
" Enable break indent
set breakindent

" Default to using spaces when hiting <Tab> key.
set expandtab
" Number of spaces that a <Tab> counts for while editing.
set softtabstop=4
" Number of spaces that a <Tab> in the file counts for.
set tabstop=4
" Number of spaces to use for each step of (auto)indent. Zero means "same as
" tabstop".
set shiftwidth=0

" At least 8 line visible buffer when moving up/down file.
set scrolloff=8
" show sign column even when empty
set signcolumn=yes
" Decrease update time
set updatetime=250
set timeoutlen=300
" visual line column(s)
set colorcolumn=80

" System friendly settings
" Using system clipboard pulled from: http://vimcasts.org/episodes/accessing-the-system-clipboard-from-vim/
" Use system clipboard for Yank and Put
set clipboard=unnamed
if has('unnamedplus')
    "Use system AND xterm clipboards for Yank and Put
    set clipboard+=unnamedplus
endif

" [[ Keymaps  ]]

" Keymaps for better default experience
nmap <silent> <space> <Nop>
vmap <silent> <space> <Nop>

" Easily explore filesystem
nmap <leader>e :Ex<CR>

" Jump betwen buffers easily

" Goto [b]uffer ([n]ext)
nmap <leader>bn :bnext<CR>

" Goto [b]uffer ([p]revious)
nmap <leader>bp :bprevious<CR>

" Simple fallback not requiring the quickfix buffer
" Goto [b]uffer [l]ist
" nmap <leader>bl :ls<CR>:b<Space>

" FIXME: the cclose/Qbuffers/copen sequence below causes flashing. Filtering
" out the quickfix buffer to begin with will mean closing it to begin with
" won't be necessary, which should fix the flashing.
" Original implementation found here: https://vi.stackexchange.com/a/2127/15953
command! Qbuffers call setqflist(map(filter(range(1, bufnr('$')), 'buflisted(v:val)'), '{"bufnr":v:val}'))

" Populate quickfix with [b]uffer [l]ist and open quickfix buffer with :copen
nmap <leader>bl :cclose<CR>:Qbuffers<CR>:copen<CR>

" Set [b]uffer list as [q]uickfix list
nmap <leader>bq :Qbuffers<CR>

" Qui[c]kfix [o]pen.
nmap <leader>co :copen<CR>
" Qui[c]kfix [c]lose.
nmap <leader>cc :cclose<CR>
" Jump to Qui[c]kfix [n]ext item.
nmap <leader>cn :cnext<CR>
" Jump to Qui[c]kfix [p]revious item.
nmap <leader>cp :cprevious<CR>
" Jump to Qui[c]kfix [f]irst item.
nmap <leader>cf :cfirst<CR>
" Jump to Qui[c]kfix [l]ast item.
nmap <leader>cl :clast<CR>

" [l]ocation list [o]pen.
nmap <leader>lo :lopen<CR>
" [l]ocation list [c]lose.
nmap <leader>lc :lclose<CR>
" Jump to [l]ocation list [n]ext item.
nmap <leader>ln :lnext<CR>
" Jump to [l]ocation list [p]revious item.
nmap <leader>lp :lprevious<CR>
" Jump to [l]ocation list [f]irst item.
nmap <leader>lf :lfirst<CR>
" Jump to [l]ocation list [l]ast item.
nmap <leader>ll :llast<CR>

" [t]ab [o]pen (i.e. new).
nmap <leader>to :tabnew<CR>
" [t]ab [c]lose.
nmap <leader>tc :tabclose<CR>
" goto [t]ab [n]ext.
nmap <leader>tn :tabnext<CR>
" goto [t]ab [p]revious.
nmap <leader>tp :tabprevious<CR>
" goto [t]ab [f]irst.
nmap <leader>tf :tabfirst<CR>
" goto [t]ab [l]ast.
nmap <leader>tl :tablast<CR>

" Wrap selected text in parens or quotes
" Ideas originated from links below:
" * https://superuser.com/questions/875095/adding-parenthesis-around-highlighted-text-in-vim#875160
" * https://superuser.com/questions/875095/adding-parenthesis-around-highlighted-text-in-vim#comment2405624_875160
" [w]rap in [p]arentheses.
vnoremap <leader>wp c()<Esc>P
" [w]rap in square brackets.
vnoremap <leader>w[ c[]<Esc>P
" [w]rap in [b]rackets.
vnoremap <leader>wb c{}<Esc>P
" [w]rap in a[n]gle brackets.
vnoremap <leader>wn c<><Esc>P
" [w]rap in single quotes.
vnoremap <leader>w' c''<Esc>P
" [w]rap in double [q]uotes.
vnoremap <leader>wq c""<Esc>P

" Open buffer pointed to by quickfix buffer while keeping cursor in quickfix
" buffer. Only override keymap locally in the quicklist type buffers. Original
" keymapping from here:
" https://www.reddit.com/r/vim/comments/hfovi6/comment/fvyxvwd/
au BufRead,BufNewFile * if &ft == 'qf' | nnoremap <silent> <buffer> o <CR><C-w>p | endif

" [[ Define Commands ]]
" My custom defined commands
command! -range=% StripTrailingWS <line1>,<line2>s/\s\+$//e

" Original defintion found here:
" https://vim.fandom.com/wiki/Reverse_order_of_lines
command! -range ReverseLines <line1>,<line2>g/^/m<line1>-1|nohl

" [[ VSCode notify config ]]
" Define vscode notify early so that we receive notificationsin in the right
" place when calling notify later in config and possible plugin loading.
" See docs here: https://github.com/vscode-neovim/vscode-neovim?tab=readme-ov-file#vscodenotifymsg
if has('nvim') && exists('g:vscode')
  lua 'vim.notify = require("vscode-neovim").notify'
endif

" [[ Filetype Detection ]]
au BufRead,BufNewFile *.cron setfiletype crontab
au BufRead,BufNewFile *.crontab setfiletype crontab

" [[ Plugin loading ]]

" Plugin bootstrapping
" https://github.com/junegunn/vim-plug
let s:autoload_data_dir_parent = has('nvim') ? s:data_dir . '/site' : s:data_dir
if empty(glob(s:autoload_data_dir_parent . '/autoload/plug.vim'))
  silent execute '!curl -fLo ' . s:autoload_data_dir_parent . '/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()

" Most plugins will either break vscode or are redundant
if !exists('g:vscode')
  " [[ Universal Plugins ]]
  " We start with plugins that can be used in both Vim and Neovim

  " Show marks in gutter, add some commands to ease jumping between marks
  Plug 'https://github.com/kshenoy/vim-signature'

  " XXX: signify can add a significant (~800 ms) amount of start up time to nvim
  " Get diff symbols in gutter for code tracked in a VCS (supports more than
  " just git and can easily be extended to support others)
  Plug 'https://github.com/mhinz/vim-signify'

  " Git related plugins
  Plug 'https://github.com/tpope/vim-fugitive'
  Plug 'https://github.com/tpope/vim-rhubarb'

  " Detect tabstop and shiftwidth automatically
  Plug 'https://github.com/tpope/vim-sleuth'

  " For comment/uncomment support
  Plug 'https://github.com/tpope/vim-commentary'

  " Basic Unix commands inside Vim
  Plug 'https://github.com/tpope/vim-eunuch'

  " Telescope is specified below and is a much nicer fuzzy finder, but is only
  " available for Neovim. fzf is a good fallback for vanilla Vim.
  Plug 'https://github.com/junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'https://github.com/junegunn/fzf.vim'

  " Live preview of markdown file in default browser
  Plug 'https://github.com/iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}

  " Personal fork of a plugin to highlight and modify todo.txt files
  Plug 'https://github.com/eestrada/todo.txt-vim'

  " Faster alternative to Netrw
  Plug 'https://github.com/justinmk/vim-dirvish'

  " [[ Neovim specific Plugins ]]

  " LSP Configuration & Plugins
  Plug 'https://github.com/neovim/nvim-lspconfig', has('nvim') ? {} : { 'on': [] }

  " Automatically install LSPs to stdpath for neovim
  Plug 'https://github.com/williamboman/mason.nvim', has('nvim') ? {} : { 'on': [] }
  Plug 'https://github.com/williamboman/mason-lspconfig.nvim', has('nvim') ? {} : { 'on': [] }

  " Useful status updates for LSP
  Plug 'https://github.com/j-hui/fidget.nvim', has('nvim') ? {} : { 'on': [] }

  " Additional lua configuration, makes nvim stuff amazing!
  Plug 'https://github.com/folke/neodev.nvim', has('nvim') ? {} : { 'on': [] }

  " Start Autocompletion plugins
  Plug 'https://github.com/hrsh7th/nvim-cmp', has('nvim') ? {} : { 'on': [] }

  " Snippet Engine & its associated nvim-cmp source
  Plug 'https://github.com/L3MON4D3/LuaSnip', has('nvim') ? {} : { 'on': [] }
  Plug 'https://github.com/saadparwaiz1/cmp_luasnip', has('nvim') ? {} : { 'on': [] }

  " Adds LSP completion capabilities
  Plug 'https://github.com/hrsh7th/cmp-nvim-lsp', has('nvim') ? {} : { 'on': [] }
  Plug 'https://github.com/hrsh7th/cmp-path', has('nvim') ? {} : { 'on': [] }

  " Adds a number of user-friendly snippets
  " This plugin *can* be used outside Neovim, but currently is not. Only cmp
  " is used for autocompletion, which is Neovim specific.
  Plug 'https://github.com/rafamadriz/friendly-snippets', has('nvim') ? {} : { 'on': [] }
  " End Autocompletion plugins

  " The `TSUpdate` call tends to throw errors when this is installed. Don't
  " stress, it works on Unix/Linux after the first run. Not worth looking into
  " deeper at the moment.
  Plug 'https://github.com/nvim-treesitter/nvim-treesitter', has('nvim') ? { 'do': ':TSUpdate' } : { 'on': [] }

  " Fuzzy finding stuff
  Plug 'https://github.com/nvim-lua/plenary.nvim', has('nvim') ? {} : { 'on': [] }
  Plug 'https://github.com/nvim-telescope/telescope.nvim', has('nvim') ? {} : { 'on': [] }
  Plug 'https://github.com/nvim-telescope/telescope-ui-select.nvim', has('nvim') ? {} : { 'on': [] }

  " 'ray-x/go.nvim' depends on:
  "   - 'nvim-treesitter/nvim-treesitter'
  "   - 'neovim/nvim-lspconfig
  Plug 'https://github.com/ray-x/go.nvim', has('nvim') ? {} : { 'on': [] }

  " recommended for floating window support for the go plugin above
  Plug 'https://github.com/ray-x/guihua.lua', has('nvim') ? {} : { 'on': [] }
endif

" Add local additional plugin inclusions, if any.
let s:additional_plugin_defs = s:config_dir . '/local_configs/additional_plugins.vim'
if filereadable(s:additional_plugin_defs)
  execute 'source ' . s:additional_plugin_defs
endif

" Any plugin configuration for local plugins should be done in
" $NVIM_CONFIG/after/plugin/local_config.lua

" Close plugin loading AFTER we load local plugin inclusions (if any exist).
call plug#end()

" [[ init after plugin load]]

" Code that should run *after* plugins are loaded
function s:vimrc_init() abort
  " [[ Configure vim-signature ]]
  " Use Signature commands if present, otherwise fallback to foolproof default
  if exists(':SignatureListGlobalMarks') > 0
    " List [m]arks that are defined [g]lobally
    nmap <leader>mg :SignatureListGlobalMarks<CR>
    " List [m]arks that are defined in current [b]uffer
    nmap <leader>mb :SignatureListBufferMarks<CR>
  else
    " List [m]arks that are defined [g]lobally
    nmap <leader>mg :marks ABCDEFGHIJKLMNOPQRSTUVWXYZ<CR>:\'
    " List [m]arks that are defined in current [b]uffer
    nmap <leader>mb :marks abcdefghijklmnopqrstuvwxyz<CR>:\'
  endif

  " [[ Configure vim-signify ]]
  let g:signify_sign_delete='-'

  nmap <leader>hu :SignifyHunkUndo<CR>
  nmap <leader>hd :SignifyHunkDiff<CR>

  " I'm still on the fence on whether or not I want to show the count of deleted
  " lines in the gutter.
  " vim.g.signify_sign_show_count = false

  " If `$GIT_EXEC` is defined, then nvim is most likely running as an editor for
  " a git commit message. We should disable signify so that it doesn't
  " unintentionally corrupt the git repo.
  "has_key(environ(), 'GIT_EXEC')
  if has_key(environ(), 'GIT_EXEC') && exists(':SignifyDisableAll')
    execute SignifyDisableAll
  end

  if !has('nvim')
    " [[ Configure fzf keybindings ]]
    " [s]earch [b]uffers
    nmap <leader>sb :Buffers<CR>

    " [s]earch [c]ommands
    nmap <leader>sc :Commands<CR>

    " [s]earch file contents with [g]rep
    nmap <leader>sg :Rg<CR>

    " [s]earch [h]elp tags
    nmap <leader>sh :Helptags<CR>

    " [s]earch [k]eymaps
    nmap <leader>sk :Maps<CR>

    " [s]earch project [p]aths
    nmap <leader>sp :Files<CR>

    " [s]earch [v]ersion controlled file paths
    nmap <leader>sv :GitFiles<CR>

    " [s]earch [s]nippets
    nmap <leader>ss :Snippets<CR>
  endif
endfunction

" Only run once Vim has actually loaded using `VimEnter` event
" Should be safe in both Vim and Neovim, so long as we aren't in vscode
if !exists('g:vscode')
  autocmd VimEnter * call s:vimrc_init()
endif
