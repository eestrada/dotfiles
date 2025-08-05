" vim: set foldmethod=marker foldlevel=0:
" Kind of pointless, but better safe than sorry.
set nocompatible

" Use this augroup for all autocmds defined in the vimrc file.
augroup vimrc_aug
  autocmd!
augroup END

" [[ Global Variables ]] {{{1

" Set <space> as the leader key
" See `:help mapleader`
"  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
let g:mapleader = ' '
let g:maplocalleader = ' '

" For vim-polyglot
" Disable individual language packs (since some cause issues).
if has('nvim')
  " Markdown has issues with URLs, at least in neovim.
  let g:polyglot_disabled = ['markdown']
endif

" For vim-test
let g:test#strategy = 'make_bang'

" How to split windows when running Plug commands
let g:plug_window = 'vnew'

" For Signify

" I'm still on the fence on whether or not I want to show the count of deleted
" lines in the gutter.
" let g:signify_sign_show_count = v:false

let g:signify_sign_delete = '-'

" Disable signify for git commits
" so that it doesn't unintentionally corrupt the git repo.
let g:signify_skip_filetype = { 'gitcommit': 1 }

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

" For zig ftplugin
if has('nvim')
  " In nvim, the `nvim-lint` and `conform.nvim` plugins do the same things.
  let g:zig_fmt_autosave = 0
endif

" Set conform variable so that it comes up in autocomplete contexts
let g:conform_autoformat = v:false

" Neovide settings
" https://neovide.dev/faq.html#how-to-turn-off-all-animations
let g:neovide_position_animation_length = 0
let g:neovide_cursor_animation_length = 0.00
let g:neovide_cursor_trail_size = 0
let g:neovide_cursor_animate_in_insert_mode = v:false
let g:neovide_cursor_animate_command_line = v:false
let g:neovide_scroll_animation_far_lines = 0
let g:neovide_scroll_animation_length = 0.00

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

" Automatically re-read changed files without asking.
set autoread

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
set completeopt=menu,menuone,noselect,noinsert,preview

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

" When wrap is turned on
" then break at words/punctuation,
" not characters.
set linebreak

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

" Indent Settings
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
if has('nvim')
  " nvim allows setting max width
  set signcolumn=auto:2
else
  set signcolumn=auto
endif

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
set statusline+=\ %t
set statusline+=%w
set statusline+=%h
set statusline+=%r
set statusline+=%m
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
  if l:mode==#'n'
    return 'NORMAL'
  elseif l:mode==?'v'
    return 'VISUAL'
  elseif l:mode==#'i'
    return 'INSERT'
  elseif l:mode==#'R'
    return 'REPLACE'
  elseif l:mode==?'s'
    return 'SELECT'
  elseif l:mode==#'t'
    return 'TERMINAL'
  elseif l:mode==#'c'
    return 'COMMAND'
  elseif l:mode==#'!'
    return 'SHELL'
  else
    return 'Mode:'.l:mode
  endif
endfunction

function! StatuslineGitBranch()
  let b:gitbranch_l_paren='('
  let b:gitbranch_r_paren=')'
  let b:gitbranch_no_repo = '-_-'
  let b:gitbranch=b:gitbranch_l_paren.b:gitbranch_no_repo.b:gitbranch_r_paren
  if &modifiable
    try
      let l:dir=expand('%:p:h')
      " TODO: add system call to check if worktree is dirty, and add a `!` or
      " some other symbol to statusline to indicate this. Command should be
      " `git diff-index -quiet HEAD --`. See link:
      " https://stackoverflow.com/a/2659808/1733321
      let l:gitrevparse = system('git -C '.l:dir.' rev-parse --abbrev-ref HEAD')
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

" Jump between windows
" Jump to previous (i.e. above/left) window.
nmap [w :wincmd W<CR>
" Jump to next (i.e. below/right) window.
nmap ]w :wincmd w<CR>
" Jump to first (i.e. top-left) window.
nmap [W :wincmd t<CR>
" Jump to last (i.e. bottom-right) window.
nmap ]W :wincmd b<CR>

" nvim has these defined, and with more features (like taking a count):
" https://github.com/neovim/neovim/pull/28525
if !has('nvim-0.11')
  " Jump between files specified as arguments
  " Go to previous buffer
  nmap [a :<C-U>execute ":" .. v:count1 .. "previous"<CR>
  " Go to next buffer
  nmap ]a :<C-U>execute ":" .. v:count1 .. "next"<CR>
  " Go to first buffer
  nmap [A :first<CR>
  " Go to next buffer
  nmap ]A :last<CR>

  " Jump between buffers
  " Go to previous buffer
  nmap [b :<C-U>execute ":" .. v:count1 .. "bprevious"<CR>
  " Go to next buffer
  nmap ]b :<C-U>execute ":" .. v:count1 .. "bnext"<CR>
  " Go to first buffer
  nmap [B :bfirst<CR>
  " Go to next buffer
  nmap ]B :blast<CR>

  " Jump between tags
  " Jump to previous tag.
  nmap [t :<C-U>execute ":" .. v:count1 .. "tprevious"<CR>
  " Jump to next tag.
  nmap ]t :<C-U>execute ":" .. v:count1 .. "tnext"<CR>
  " Jump to first tag.
  nmap [T :tfirst<CR>
  " Jump to last tag.
  nmap ]T :tlast<CR>

  " Jump to previous Quickfix item.
  nmap [q :<C-U>execute ":" .. v:count1 .. "cprevious"<CR>
  " Jump to next Quickfix item.
  nmap ]q :<C-U>execute ":" .. v:count1 .. "cnext"<CR>
  " Jump to first Quickfix item.
  nmap [Q :cfirst<CR>
  " Jump to last Quickfix item.
  nmap ]Q :clast<CR>

  " Jump to previous location list item.
  nmap [l :<C-U>execute ":" .. v:count1 .. "lprevious"<CR>
  " Jump to next location list item.
  nmap ]l :<C-U>execute ":" .. v:count1 .. "lnext"<CR>
  " Jump to first location list item.
  nmap [L :lfirst<CR>
  " Jump to last location list item.
  nmap ]L :llast<CR>
endif

" Original implementation found here: https://vi.stackexchange.com/a/2127/15953
command! Qbuffers call setqflist(map(filter(range(1, bufnr('$')), 'buflisted(v:val)'), '{"bufnr":v:val}'))

" Fill loclist with all open buffers.
command! Lbuffers call setloclist(winnr(), map(filter(range(1, bufnr('$')), 'buflisted(v:val)'), '{"bufnr":v:val}'))

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
autocmd vimrc_aug BufRead,BufNewFile * if &ft == 'qf' | nnoremap <silent> <buffer> p <CR><C-w>p | endif

" [[ User Commands ]] {{{1
" My custom defined commands
command! -range=% StripTrailingWS <line1>,<line2>s/\s\+$//e

" Original definition found here:
" https://vim.fandom.com/wiki/Reverse_order_of_lines
command! -range ReverseLines <line1>,<line2>g/^/m<line1>-1|nohl

" Requires `jq` CLI be installed.
" Original based on link below :
" * https://gist.github.com/angelo-v/e0208a18d455e2e6ea3c40ad637aac53?permalink_comment_id=3439919#gistcomment-3439919
command! JWTUnpackPayload .!jq --compact-output --raw-input 'gsub("-";"+") | gsub("_";"/") | split(".") | .[1] | @base64d | fromjson'

" Requires that python3 be installed
" Original based on link:
" https://gist.github.com/atripes/15372281209daf5678cded1d410e6c16?permalink_comment_id=3781583#gistcomment-3781583
command! -range UrlEncode <line1>,<line2>!python3 -c 'import sys; from urllib import parse; print(parse.quote_plus(sys.stdin.read().strip()))'<cr>

" Delete all buffers other than the current one. Originally found here:
" https://www.reddit.com/r/neovim/comments/s7m0xg/comment/htbfaav/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
command! BuffDeleteOthers :%bdelete|edit #|normal`"<cr>

" [[ Filetype Detection ]] {{{1
autocmd vimrc_aug BufRead,BufNewFile *.cron setfiletype crontab
autocmd vimrc_aug BufRead,BufNewFile *.crontab setfiletype crontab
autocmd vimrc_aug BufRead,BufNewFile *.zon setfiletype zig

" [[ Plugins ]] {{{1

" Based off formula here: https://github.com/junegunn/vim-plug/wiki/tips#conditional-activation
function! Cond(cond, ...)
  let opts = get(a:000, 0, {})
  return a:cond ? opts : extend(opts, { 'on': [], 'for': [] })
endfunction

let s:autoload_data_dir_parent = has('nvim') ? s:data_dir . '/site' : s:data_dir
if empty(glob(s:autoload_data_dir_parent . '/autoload/plug.vim'))
  silent execute '!curl -fLo ' . s:autoload_data_dir_parent . '/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd vimrc_aug VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin(s:plugins_dir)
" This allows for offline help (e.g. `:help plug-options`),
" otherwise it isn't necessary to use vim-plug functionality.
Plug 'https://github.com/junegunn/vim-plug'

" [[ Neovim native (e.g. not embedded in vscode) ]] {{{2

" WARNING: load LSP plugins before anything else, otherwise LSPs may not
" autostart properly.

" LSP Configuration & Plugins
Plug 'https://github.com/neovim/nvim-lspconfig', Cond(has('nvim') && !exists('g:vscode'))

" Get diagnostics for entire LSP workspace
Plug 'https://github.com/artemave/workspace-diagnostics.nvim', Cond(has('nvim') && !exists('g:vscode'))

" Useful status updates for LSP
Plug 'https://github.com/j-hui/fidget.nvim', Cond(has('nvim') && !exists('g:vscode'))

" Additional lua configuration, makes nvim stuff amazing!
Plug 'https://github.com/folke/neodev.nvim', Cond(has('nvim') && !exists('g:vscode'))

" General DAP plugins
Plug 'https://github.com/mfussenegger/nvim-dap', Cond(has('nvim') && !exists('g:vscode'))
Plug 'https://github.com/nvim-neotest/nvim-nio', Cond(has('nvim') && !exists('g:vscode'))
Plug 'https://github.com/rcarriga/nvim-dap-ui', Cond(has('nvim') && !exists('g:vscode'))

" Specific DAP plugins
Plug 'https://github.com/suketa/nvim-dap-ruby', Cond(has('nvim') && !exists('g:vscode'))

" Specialized LSP for extra Java jdtls
Plug 'https://github.com/mfussenegger/nvim-jdtls', Cond(has('nvim') && !exists('g:vscode'))

" Start Autocompletion plugins
Plug 'https://github.com/hrsh7th/nvim-cmp', Cond(has('nvim') && !exists('g:vscode'))

" LuaSnip Snippet Engine & its associated nvim-cmp source
Plug 'https://github.com/L3MON4D3/LuaSnip', Cond(has('nvim') && !exists('g:vscode'))
Plug 'https://github.com/saadparwaiz1/cmp_luasnip', Cond(has('nvim') && !exists('g:vscode'))

" vim-vsnip Snippet Engine & its associated nvim-cmp source
"
" I tried out vim-vsnip since is written in pure vimscript
" and can technically work in Vanilla vim.
" I thought "Hey, if I can get this working,
" maybe I can also get a completion set up that will work for Vanilla vim as well".
"
" However, after trying it for a bit, it is slow enough to be painful
" (at least compared to LuaSnip).
" It is also slightly less featureful.
" The lack of features wouldn't be such a big issue, except it is slow.
" That is pretty much a deal breaker.
"
" Leaving this here for reference.
"
" Plug 'https://github.com/hrsh7th/vim-vsnip', Cond(has('nvim') && !exists('g:vscode'))
" Plug 'https://github.com/hrsh7th/cmp-vsnip', Cond(has('nvim') && !exists('g:vscode'))

" Add additional completion sources for nvim-cmp.
Plug 'https://github.com/hrsh7th/cmp-nvim-lsp', Cond(has('nvim') && !exists('g:vscode'))
Plug 'https://github.com/hrsh7th/cmp-path', Cond(has('nvim') && !exists('g:vscode'))
Plug 'https://github.com/hrsh7th/cmp-buffer', Cond(has('nvim') && !exists('g:vscode'))
" Plug 'https://github.com/hrsh7th/cmp-cmdline', Cond(has('nvim') && !exists('g:vscode'))
Plug 'https://github.com/lukas-reineke/cmp-rg', Cond(has('nvim') && !exists('g:vscode'))

" End Autocompletion plugins

" The `TSUpdate` call tends to throw errors when this is installed. Don't
" stress, it works on Unix/Linux after the first run. Not worth looking into
" deeper at the moment.
Plug 'https://github.com/nvim-treesitter/nvim-treesitter', Cond(has('nvim') && !exists('g:vscode'), { 'do': ':TSUpdate' })
Plug 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects', Cond(has('nvim') && !exists('g:vscode'))

" TODO: Consider deleting. Most of this can be done with native Vim features
" or periscope.

" Fuzzy finding stuff
Plug 'https://github.com/nvim-lua/plenary.nvim', Cond(has('nvim') && !exists('g:vscode'))
Plug 'https://github.com/nvim-telescope/telescope.nvim', Cond(has('nvim') && !exists('g:vscode'))

" LLM stuff
" Plug 'https://github.com/huggingface/llm.nvim', Cond(has('nvim') && !exists('g:vscode'))
Plug 'https://github.com/David-Kunz/gen.nvim', Cond(has('nvim') && !exists('g:vscode'))
Plug 'https://github.com/github/copilot.vim', Cond(has('nvim') && !exists('g:vscode'))
Plug 'https://github.com/CopilotC-Nvim/CopilotChat.nvim', Cond(has('nvim') && !exists('g:vscode'))

" UI stuff
Plug 'https://github.com/stevearc/dressing.nvim', Cond(has('nvim') && !exists('g:vscode'))

" linting
Plug 'https://github.com/mfussenegger/nvim-lint', Cond(has('nvim') && !exists('g:vscode'))
" Plug 'git@github.com:eestrada/nvim-lint.git', Cond(has('nvim') && !exists('g:vscode'))
" Plug 'https://github.com/eestrada/nvim-lint', Cond(has('nvim') && !exists('g:vscode'))

" Show marks in sign column
Plug 'https://github.com/chentoast/marks.nvim', Cond(has('nvim') && !exists('g:vscode'))

" [[ Vim and Neovim native (e.g. not embedded in vscode) ]] {{{2

" Adds a number of user-friendly snippets
" This plugin *can* be used outside Neovim, but currently is not. Only cmp
" is used for autocompletion, which is Neovim specific.
Plug 'https://github.com/rafamadriz/friendly-snippets', Cond(!exists('g:vscode'))

" XXX: signify can add a significant (~800 ms) amount of start up time to nvim
" Get diff symbols in gutter for code tracked in a VCS (supports more than
" just git and can easily be extended to support others)
Plug 'https://github.com/mhinz/vim-signify', Cond(!exists('g:vscode'))

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

" Includes most languages not already included by default with Vim or Neovim
Plug 'https://github.com/sheerun/vim-polyglot', Cond(!exists('g:vscode'))

" voll
Plug 'https://github.com/eestrada/voll', Cond(!exists('g:vscode'), { 'rtp': 'vim' })
" Plug '~/dev/voll', Cond(!exists('g:vscode'), { 'rtp': 'vim' })

" [[ Vim and Neovim anywhere ]] {{{2
" We start with plugins that can be used in both Vim and Neovim

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

" Better pair matching than builtin matchit
Plug 'https://github.com/andymass/vim-matchup'

" [[ Neovim anywhere ]] {{{2

" TODO: Consider deleting. Native vim abilities can do most of this, or just
" use telescope. Or finish periscope and remove telescope.

" Periscope
" FIXME: currently a lot of Telescope
" functionality remains after fork. Once everything uses `vim.ui.select`, then
" it should be safe to run everywhere, including VSCode.
" XXX: Use an ssh URL while still actively developing plugin.
"Plug 'git@github.com:eestrada/periscope.nvim.git', Cond(has('nvim'))
Plug 'https://github.com/eestrada/periscope.nvim', Cond(has('nvim'))

" Pickers for everywhere nvim is available, including VSCode. Inspiration for
" periscope.
Plug 'https://github.com/mfussenegger/nvim-qwahl', Cond(has('nvim'))

" Automatically install common tools to stdpath for neovim
Plug 'https://github.com/williamboman/mason.nvim', Cond(has('nvim'))
Plug 'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim', Cond(has('nvim'))

" formatting
Plug 'https://github.com/stevearc/conform.nvim', Cond(has('nvim'))

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
  if exists('g:loaded_signify')
    nmap <leader>hu :SignifyHunkUndo<CR>
    nmap <leader>hd :SignifyHunkDiff<CR>

    " Text object for moving over everything in or around a changed hunk:
    omap ic <plug>(signify-motion-inner-pending)
    xmap ic <plug>(signify-motion-inner-visual)
    omap ac <plug>(signify-motion-outer-pending)
    xmap ac <plug>(signify-motion-outer-visual)
  endif

  " Make Netrw commands use Dirvish instead
  " see :help dirvish
  if exists('g:loaded_dirvish')
    let g:loaded_netrwPlugin = 1

    command! -nargs=? -complete=dir Explore Dirvish <args>
    command! -nargs=? -complete=dir Sexplore belowright split | silent Dirvish <args>
    command! -nargs=? -complete=dir Vexplore leftabove vsplit | silent Dirvish <args>
  endif

  " Use Fugitive `:Gclog` to grep git history for word under cursor and place
  " results into Quicklist. Only shows lines that changed between commits.
  if exists('g:loaded_fugitive')
    nnoremap <leader>vg :Gclog "-G<cword>" --<CR>
    vnoremap <leader>vg y:Gclog "-G<C-R>0" --<CR>
  endif

  " Add command for formatting markdown tables using easy align.
  if exists('g:loaded_easy_align_plugin')
    " By default this will only format the current line
    command! -range -nargs=0 MarkdownFormatTable <line1>,<line2>EasyAlign *<Bar>
  endif

  " rg is used by default in nvim when available, but not vim.
  if executable('rg')
    " How to ignore `.git` dir: https://news.ycombinator.com/item?id=33238626
    let &grepprg='rg --vimgrep --hidden --glob ''!.git/'' --smart-case'
    let &grepformat='%f:%l:%c:%m'

    " grep the local directory for the word under the cursor
    nnoremap <leader>gg :grep "<cword>" ./<CR>
    vnoremap <leader>gg y:grep "<C-R>0" ./<CR>
  endif

  if exists('g:loaded_copilot_chat')
    " Possible configuration options:
    " https://github.com/CopilotC-Nvim/CopilotChat.nvim?tab=readme-ov-file#configuration
    lua require("CopilotChat").setup({})
  endif

  if exists('g:loaded_copilot')
    " Copilot is only used for authentication.
    " Copilot chat is actually used for functionality.
    exec 'Copilot disable'
  endif
endfunction

" Only run once Vim has actually loaded using `VimEnter` event
autocmd vimrc_aug VimEnter * call s:vimrc_init()
