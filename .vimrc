" vim: set foldmethod=marker:
" Kind of pointless, but better safe than sorry.
set nocompatible

" TODO: seek some inspiration from the configuration(s) generated from
" https://vim-bootstrap.com/ . It seems to have some good ideas and points to
" lots of plugins that should help with language editing that do not require
" LSP to be setup correctly.

" [[ Global Variables ]] {{{1

" Set <space> as the leader key
" See `:help mapleader`
"  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
let g:mapleader = ' '
let g:maplocalleader = ' '

" For vim-test
if has('nvim')
  let g:test#strategy = 'neovim'
endif

"*****************************************************************************
"" Convenience variables
"*****************************************************************************

" MarkdownPreview settings

" set to 1, the nvim will auto close current preview window when changing
" from Markdown buffer to another buffer
" default: 1
let g:mkdp_auto_close = 0

" set to 1, Vim will refresh Markdown when saving the buffer or
" when leaving insert mode. Default 0 is auto-refresh Markdown as you edit or
" move the cursor
" default: 0
let g:mkdp_refresh_slow = 1

" Neovim will use `xdg-open` by default. WSL2 will set this to something that
" can be opened in Windows directly. No special config is necessary here, just
" make sure to install xdg-open and Neovim will do the right thing.
" https://superuser.com/a/1687625/474473
"
" If things are really bad and that doesn't work, set g:netrw_browsex_viewer,
" like mentioned below. You can use `sensible-browser` on Debian based
" systems. Or you can install and use `wslview`. However, all of these things
" should not be necessary if `xdg-open` is available.
" * https://neovim.io/doc/user/pi_netrw.html#netrw_filehandler

" [[ Utility variables ]] {{{1
let s:is_win = has('win32')
let s:vim_dir = $HOME . (s:is_win ? '/vimfiles' : '/.vim')
let s:plugins_dir = s:vim_dir . '/plugged'

let s:data_dir = has('nvim') ? stdpath('data') : s:vim_dir
let s:state_dir = has('nvim') ? stdpath('state') : s:vim_dir . '/state'
let s:config_dir = has('nvim') ? stdpath('config') : s:vim_dir

" [[ Options ]] {{{1

"" Encoding
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8
set ttyfast

" Don't create swap files by default
set updatecount=0

" Enable mouse mode
set mouse=a

" Save undo history
set undofile
if !has('nvim')
  " The Vim default is the current directory `.` This ends up causing lots of
  " junk being scattered around. Use data directory or /tmp
  let s:undo_dir = s:state_dir . '/undo'
  let &undodir = s:undo_dir
endif
set undodir+=/tmp/

" Case-insensitive searching UNLESS \C or capital in search
set ignorecase
set smartcase

" When there is a search pattern, do no highlight all matches.
set nohlsearch
" Incremental search highlight. Useful for constructing regexes.
set incsearch

" how to save newlines
set fileformats=unix,dos,mac

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

" Show line and column number.
set ruler
" Print the line number in front of cursor line.
set number
" Print the relative line number in front of each line other than cursor line.
" set relativenumber
" Minimal number of columns to use for the line number.
set numberwidth=4
" make backspace work line most other apps
set backspace=2

" Highlight cursor line
set cursorline

" Tab Settings
" Copy indent from current line when starting a new line.
set autoindent
" Use indent rules based on current filetype.
set smartindent
" Enable break indent
set breakindent

" Default to using spaces when hitting <Tab> key.
set expandtab
" Number of spaces that a <Tab> in the file counts for.
set tabstop=4
" Number of spaces to use for each step of (auto)indent. Zero means "same as
" tabstop".
set shiftwidth=0
" Number of spaces that a <Tab> counts for while editing. Negative means "same
" as shiftwidth."
set softtabstop=-1

" At least 8 line visible buffer when moving up/down file.
set scrolloff=4
" show sign column even when empty
set signcolumn=auto
" Decrease update time
set updatetime=250
set timeoutlen=600
" visual line column(s)
set colorcolumn=80

"" Use modeline overrides
set modeline
set modelines=10

set title
set titleold="Terminal"
set titlestring=%F

" Status bar
set laststatus=2

" How to figure out the names of available statusline colors:
" https://shapeshed.com/vim-statuslines/#colour
set statusline=
set statusline+=%#PmenuSel#
set statusline+=\ %{StatuslineMode()}
set statusline+=\ %{b:gitbranch}
set statusline+=\ %#Question#
set statusline+=\ %f
set statusline+=%=
set statusline+=\ %#CursorLineNr#
set statusline+=%y
set statusline+=%#MoreMsg#
set statusline+=\ %{strlen(&fenc)?&fenc:'none'}
set statusline+=%#LineNr#
set statusline+=[%{&ff}]
set statusline+=\ %#ModeMsg#
set statusline+={%p%%,\ line\ %l/%L,\ col\ %c}

function! StatuslineMode()
  let l:mode=mode()
  if l:mode==#"n"
    return "NORMAL"
  elseif l:mode==?"v"
    return "VISUAL"
  elseif l:mode==#"i"
    return "INSERT"
  elseif l:mode==#"R"
    return "REPLACE"
  elseif l:mode==?"s"
    return "SELECT"
  elseif l:mode==#"t"
    return "TERMINAL"
  elseif l:mode==#"c"
    return "COMMAND"
  elseif l:mode==#"!"
    return "SHELL"
  else
    return "Mode:".l:mode
  endif
endfunction

function! StatuslineGitBranch()
  let b:gitbranch_l_paren="("
  let b:gitbranch_r_paren=")"
  let b:gitbranch_no_repo = "-_-"
  let b:gitbranch=b:gitbranch_l_paren.b:gitbranch_no_repo.b:gitbranch_r_paren
  if &modifiable
    try
      let l:dir=expand('%:p:h')
      " TODO: add system call to check if worktree is dirty, and add a `!` or
      " some other symbol to statusline to indicate this. Command should be
      " `git diff-index -quiet HEAD --`. See link:
      " https://stackoverflow.com/a/2659808/1733321
      let l:gitrevparse = system("git -C ".l:dir." rev-parse --abbrev-ref HEAD")
      if !v:shell_error
        let b:gitbranch=b:gitbranch_l_paren.substitute(l:gitrevparse, '\n', '', 'g').b:gitbranch_r_paren
      endif
    catch
    endtry
  endif
endfunction

augroup GetGitBranch
  autocmd!
  autocmd VimEnter,WinEnter,BufEnter * call StatuslineGitBranch()
augroup END

" System friendly settings
" Using system clipboard pulled from: http://vimcasts.org/episodes/accessing-the-system-clipboard-from-vim/
" Use system clipboard for Yank and Put
set clipboard=unnamed
if has('unnamedplus')
    "Use system AND xterm clipboards for Yank and Put
    set clipboard+=unnamedplus
endif

" [[ Keymaps  ]] {{{1

" Keymaps for better default experience
nmap <silent> <space> <Nop>
vmap <silent> <space> <Nop>

" Easily explore file system
" NOTE: if Dirvish has been loaded, it will overload `:Explore`. See below.
nmap <leader>e :Explore<CR>

" Buffers/windows/tabs
" see :help windows

" Jump between buffers
" Go to previous buffer
nmap [b :bprevious<CR>
" Go to next buffer
nmap ]b :bnext<CR>
" Go to first buffer
nmap [B :bfirst<CR>
" Go to next buffer
nmap ]B :blast<CR>

" Jump between windows
" Jump to previous (i.e. above/left) window.
nmap [w :wincmd W<CR>
" Jump to next (i.e. below/right) window.
nmap ]w :wincmd w<CR>
" Jump to first (i.e. top-left) window.
nmap [W :wincmd t<CR>
" Jump to last (i.e. bottom-right) window.
nmap ]W :wincmd b<CR>

" Jump between tabs
" Jump to previous tab.
nmap [t :tabprevious<CR>
" Jump to next tab.
nmap ]t :tabnext<CR>
" Jump to first tab.
nmap [T :tabfirst<CR>
" Jump to last tab.
nmap ]T :tablast<CR>

" " Original implementation found here: https://vi.stackexchange.com/a/2127/15953
command! Qbuffers call setqflist(map(filter(range(1, bufnr('$')), 'buflisted(v:val)'), '{"bufnr":v:val}'))

" FIXME: figure out how to indicate the current window for command below. <window> isn't it, obviously.
command! Lbuffers call setloclist(<window>, map(filter(range(1, bufnr('$')), 'buflisted(v:val)'), '{"bufnr":v:val}'))

" Jump to previous Quickfix item.
nmap [q :cprevious<CR>
" Jump to next Quickfix item.
nmap ]q :cnext<CR>
" Jump to first Quickfix item.
nmap [Q :cfirst<CR>
" Jump to last Quickfix item.
nmap ]Q :clast<CR>

" Jump to previous location list item.
nmap [l :lprevious<CR>
" Jump to next location list item.
nmap ]l :lnext<CR>
" Jump to first location list item.
nmap [L :lfirst<CR>
" Jump to last location list item.
nmap ]L :llast<CR>

" Jump to previous location in jump list.
nmap [j <C-O>
" Jump to next location in jump list.
nmap ]j <C-i>

" The keymap [I is always defined to reveal references. I'm fairly certain
" this is based on references found in a ctags file. Depending on
" configuration, it may not do anything, but the keymap should always be
" defined. Just force `gr` to point to that. This should work in Vim, Neovim,
" and Neovim embedded in VSCode.
nmap gr [I

" The keymap <C-]> is always defined to go to a function/variable definition
" in a ctags file. Depending on configuration, it may not do anything, but the
" keymap should always be defined. Just force `gd` to point to that. This
" should work in Vim, Neovim, and Neovim embedded in VSCode. See link here:
" https://hea-www.harvard.edu/~fine/Tech/vi.html
nmap gd <C-]>

" [[ Toggling keymaps ]]
" Toggle spellcheck
nmap <leader>ts :set spelllang=en_us spell! spell?<CR>
" Toggle relative line numbers
nmap <leader>tr :set relativenumber! relativenumber?<CR>
" Toggle search highlight
nmap <leader>th :set hlsearch! hlsearch?<CR>
" Toggle cursor line highlight
nmap <leader>tc :set cursorline! cursorline?<CR>

" Search for most recently yanked text
nmap <leader>sy :execute '/' . @0<CR>

" [[ Autocommands ]] {{{1
" Open buffer pointed to by quickfix buffer while keeping cursor in quickfix
" buffer. Only override keymap locally in the quicklist type buffers. Original
" keymapping from here:
" https://www.reddit.com/r/vim/comments/hfovi6/comment/fvyxvwd/
au BufRead,BufNewFile * if &ft == 'qf' | nnoremap <silent> <buffer> p <CR><C-w>p | endif

" [[ User Commands ]] {{{1
" My custom defined commands
command! -range=% StripTrailingWS <line1>,<line2>s/\s\+$//e

" Original defintion found here:
" https://vim.fandom.com/wiki/Reverse_order_of_lines
command! -range ReverseLines <line1>,<line2>g/^/m<line1>-1|nohl

" Requires `jq` CLI be installed.
" Original based on link below :
" * https://gist.github.com/angelo-v/e0208a18d455e2e6ea3c40ad637aac53?permalink_comment_id=3439919#gistcomment-3439919
command! JWTUnpackPayload .!jq --compact-output --raw-input 'gsub("-";"+") | gsub("_";"/") | split(".") | .[1] | @base64d | fromjson'

" Requires `jq` CLI be installed.
command! -range=% JSONFormat <line1>,<line2>!jq .

" Requires `jq` CLI be installed.
command! -range=% JSONCompact <line1>,<line2>!jq --compact-output .

" Requires that python3 be installed
" Original based on link:
" https://gist.github.com/atripes/15372281209daf5678cded1d410e6c16?permalink_comment_id=3781583#gistcomment-3781583
command! -range UrlEncode <line1>,<line2>!python3 -c 'import sys; from urllib import parse; print(parse.quote_plus(sys.stdin.read().strip()))'<cr>

" Delete all buffers other than the current one. Originally found here:
" https://www.reddit.com/r/neovim/comments/s7m0xg/comment/htbfaav/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
command! BuffDeleteOthers :%bdelete|edit #|normal`"<cr>

" [[ Filetype Detection ]] {{{1
au BufRead,BufNewFile *.cron setfiletype crontab
au BufRead,BufNewFile *.crontab setfiletype crontab

" [[ Plugins ]] {{{1

" Based off formula here: https://github.com/junegunn/vim-plug/wiki/tips#conditional-activation
function! Cond(cond, ...)
  let opts = get(a:000, 0, {})
  return a:cond ? opts : extend(opts, { 'on': [], 'for': [] })
endfunction

let s:autoload_data_dir_parent = has('nvim') ? s:data_dir . '/site' : s:data_dir
if empty(glob(s:autoload_data_dir_parent . '/autoload/plug.vim'))
  silent execute '!curl -fLo ' . s:autoload_data_dir_parent . '/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin(s:plugins_dir)

" [[ Neovim native (e.g. not embedded in vscode) ]] {{{2

" WARNING: load LSP plugins before anything else, otherwise LSPs may not
" autostart properly.

" LSP Configuration & Plugins
Plug 'https://github.com/neovim/nvim-lspconfig', Cond(has('nvim') && !exists('g:vscode'))

" Automatically install LSPs to stdpath for neovim
Plug 'https://github.com/williamboman/mason.nvim', Cond(has('nvim') && !exists('g:vscode'))
Plug 'https://github.com/williamboman/mason-lspconfig.nvim', Cond(has('nvim') && !exists('g:vscode'))

" Useful status updates for LSP
Plug 'https://github.com/j-hui/fidget.nvim', Cond(has('nvim') && !exists('g:vscode'))

" Additional lua configuration, makes nvim stuff amazing!
Plug 'https://github.com/folke/neodev.nvim', Cond(has('nvim') && !exists('g:vscode'))

" General DAP plugins
Plug 'https://github.com/mfussenegger/nvim-dap', Cond(has('nvim') && !exists('g:vscode'))
Plug 'https://github.com/nvim-neotest/nvim-nio', Cond(has('nvim') && !exists('g:vscode'))
Plug 'https://github.com/rcarriga/nvim-dap-ui', Cond(has('nvim') && !exists('g:vscode'))

" Specialized LSP for extra Java jdtls
Plug 'https://github.com/mfussenegger/nvim-jdtls', Cond(has('nvim') && !exists('g:vscode'))

" Start Autocompletion plugins
Plug 'https://github.com/hrsh7th/nvim-cmp', Cond(has('nvim') && !exists('g:vscode'))

" Snippet Engine & its associated nvim-cmp source
Plug 'https://github.com/L3MON4D3/LuaSnip', Cond(has('nvim') && !exists('g:vscode'))
Plug 'https://github.com/saadparwaiz1/cmp_luasnip', Cond(has('nvim') && !exists('g:vscode'))

" Adds LSP completion capabilities
Plug 'https://github.com/hrsh7th/cmp-nvim-lsp', Cond(has('nvim') && !exists('g:vscode'))
Plug 'https://github.com/hrsh7th/cmp-path', Cond(has('nvim') && !exists('g:vscode'))

" Adds a number of user-friendly snippets
" This plugin *can* be used outside Neovim, but currently is not. Only cmp
" is used for autocompletion, which is Neovim specific.
Plug 'https://github.com/rafamadriz/friendly-snippets', Cond(has('nvim') && !exists('g:vscode'))
" End Autocompletion plugins

" The `TSUpdate` call tends to throw errors when this is installed. Don't
" stress, it works on Unix/Linux after the first run. Not worth looking into
" deeper at the moment.
Plug 'https://github.com/nvim-treesitter/nvim-treesitter', Cond(has('nvim') && !exists('g:vscode'), { 'do': ':TSUpdate' })

" LLM stuff
Plug 'https://github.com/huggingface/llm.nvim', Cond(has('nvim') && !exists('g:vscode'))

" TODO: Consider deleting. Most of this can be done with native Vim features
" or periscope.

" Fuzzy finding stuff
Plug 'https://github.com/nvim-lua/plenary.nvim', Cond(has('nvim') && !exists('g:vscode'))
Plug 'https://github.com/nvim-telescope/telescope.nvim', Cond(has('nvim') && !exists('g:vscode'))

" UI stuff
Plug 'https://github.com/stevearc/dressing.nvim', Cond(has('nvim') && !exists('g:vscode'))

" [[ Vim and Neovim native (e.g. not embedded in vscode) ]] {{{2

" Show buffers as tabs
Plug 'https://github.com/ap/vim-buftabline', Cond(!exists('g:vscode'))

" XXX: signify can add a significant (~800 ms) amount of start up time to nvim
" Get diff symbols in gutter for code tracked in a VCS (supports more than
" just git and can easily be extended to support others)
Plug 'https://github.com/mhinz/vim-signify', Cond(!exists('g:vscode'))

" Detect tabstop and shiftwidth automatically
" WARNING: sleuth breaks more than it fixes. Is there any way to invoke it's
" functionality on demand instead of all the time?
" Plug 'https://github.com/tpope/vim-sleuth', Cond(!exists('g:vscode'))

" TODO: Consider deleting. This is built into Neovim, and can be pretty much
" done just as easily via Visual block mode.

" For comment/uncomment support
Plug 'https://github.com/tpope/vim-commentary', Cond(!exists('g:vscode'))

" For easier test running support
Plug 'https://github.com/vim-test/vim-test', Cond(!exists('g:vscode'))

" Live preview of markdown file in default browser
" Despite name, works in Vim 8.1+ as well, not just Neovim
Plug 'https://github.com/iamcco/markdown-preview.nvim', Cond(!exists('g:vscode'), { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']})

" [[ Language plugins ]] {{{3

" python
" Depending on the version of Vim/Neovim you are using, the syntax
" highlighting feature of this requirements plugin may be bundled.
Plug 'https://github.com/raimon49/requirements.txt.vim', Cond(!exists('g:vscode'), {'for': 'requirements'})

" [[ Vim and Neovim anywhere ]] {{{2
" We start with plugins that can be used in both Vim and Neovim

" Tools to manipulate CSV files
Plug 'https://github.com/chrisbra/csv.vim'

" Basic Unix commands inside Vim
Plug 'https://github.com/tpope/vim-eunuch'

" Align fields (like Markdown tables)
Plug 'https://github.com/junegunn/vim-easy-align'

" Highlight and modify todo.txt files
" Use personal fork of a plugin
Plug 'https://github.com/eestrada/todo.txt-vim'

" Faster, simpler, cleaner alternative to Netrw
Plug 'https://github.com/justinmk/vim-dirvish'

" Git related plugins
Plug 'https://github.com/tpope/vim-fugitive'
Plug 'https://github.com/tpope/vim-rhubarb'

" Compile and preview Graphviz files using `dot` utility, which must be
" installed separately.
Plug 'https://github.com/liuchengxu/graphviz.vim'

" Use system color picker to populate color values in code
Plug 'https://github.com/KabbAmine/vCoolor.vim'

" [[ Neovim anywhere ]] {{{2

" TODO: Consider deleting. Native vim abilities can do most of this, or just
" use telescope. Or finish this and remove telescope.

" Periscope
" FIXME: currently still ignored in VSCode since a lot of Telescope
" functionality remains after fork. Once everything uses `vim.ui.select`, then
" it should be safe to run everywhere, including VSCode.
" XXX: Use an ssh URL while still actively developing plugin.
"Plug 'git@github.com:eestrada/periscope.nvim.git', Cond(has('nvim') && !exists('g:vscode'))
Plug 'https://github.com/eestrada/periscope.nvim', Cond(has('nvim') && !exists('g:vscode'))

" [[ Vim only ]] {{{2

" <shrug>

" Add local additional plugin inclusions, if any.
" Local plugins must configure include guards independently
let s:additional_plugin_defs = s:config_dir . '/local_configs/additional_plugins.vim'
if filereadable(s:additional_plugin_defs)
  execute 'source ' . s:additional_plugin_defs
endif

" Any plugin configuration for local plugins should be done in
" $NVIM_CONFIG/after/plugin/local_config.lua

" Close plugin loading AFTER we load local plugin inclusions (if any exist).
call plug#end()

" [[ init after plugin load]] {{{1

" Code that should run *after* plugins are loaded
function s:vimrc_init() abort
  " [[ Configure vim-signify ]] {{{2
  " Although this global variable could be set anywhere, setting near all the
  " other Signify settings keeps things centralized.
  let g:signify_sign_delete = '-'

  if exists(':SignifyHunkUndo') > 0
    nmap <leader>hu :SignifyHunkUndo<CR>
    nmap <leader>hd :SignifyHunkDiff<CR>
  endif

  " I'm still on the fence on whether or not I want to show the count of deleted
  " lines in the gutter.
  " vim.g.signify_sign_show_count = false

  " If `$GIT_EXEC` is defined, then nvim is most likely running as an editor for
  " a git commit message. We should disable signify so that it doesn't
  " unintentionally corrupt the git repo.
  if has_key(environ(), 'GIT_EXEC') && exists(':SignifyDisableAll')
    execute SignifyDisableAll
  end

  " Make Netrw commands use Dirvish instead
  " see :help dirvish
  if exists(':Dirvish')
    let g:loaded_netrwPlugin = 1

    command! -nargs=? -complete=dir Explore Dirvish <args>
    command! -nargs=? -complete=dir Sexplore belowright split | silent Dirvish <args>
    command! -nargs=? -complete=dir Vexplore leftabove vsplit | silent Dirvish <args>
  endif

  " Use Fugitive `:Gclog` to grep git history for word under cursor and place
  " results into Quicklist. Only shows lines that changed between commits.
  if exists(':Gclog')
    nnoremap <leader>vg :Gclog "-G<cword>" --<CR>
    vnoremap <leader>vg y:Gclog "-G<C-R>0" --<CR>
  endif

  " Add command for formatting markdown tables using easy align. The command
  if exists(':EasyAlign')
    " By default this will only format the current line
    command! -range -nargs=0 MarkdownFormatTable <line1>,<line2>EasyAlign *<Bar>
  endif
endfunction

" Only run once Vim has actually loaded using `VimEnter` event
autocmd VimEnter * call s:vimrc_init()
