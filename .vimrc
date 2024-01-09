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

" [[ Setting options ]]
" Don't create swapfiles by default
set updatecount=0

" Enable mouse mode
set mouse=a

" Save undo history
set undofile

" Case-insensitive searching UNLESS \C or capital in search
set ignorecase
set smartcase

" Set completeopt to have a better completion experience
set completeopt=menuone,noselect

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
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()

" Most plugins will either break vscode or are redundant
if !exists('g:vscode')
  " Show marks in gutter, add some commands to ease jumping between marks
  Plug 'https://github.com/kshenoy/vim-signature'

  " XXX: signify can add a significant (~800 ms) amount of start up time to nvim
  " Get diff symbols in gutter for code tracked in a VCS (supports more than
  " just git and can easily be extended to support others)
  Plug 'https://github.com/mhinz/vim-signify'

  " LSP Configuration & Plugins
  Plug 'https://github.com/neovim/nvim-lspconfig'

  " Automatically install LSPs to stdpath for neovim
  Plug 'https://github.com/williamboman/mason.nvim'
  Plug 'https://github.com/williamboman/mason-lspconfig.nvim'

  " Useful status updates for LSP
  Plug 'https://github.com/j-hui/fidget.nvim'

  " Additional lua configuration, makes nvim stuff amazing!
  Plug 'https://github.com/folke/neodev.nvim'

  " Start Autocompletion plugins
  Plug 'https://github.com/hrsh7th/nvim-cmp'

  " Snippet Engine & its associated nvim-cmp source
  Plug 'https://github.com/L3MON4D3/LuaSnip'
  Plug 'https://github.com/saadparwaiz1/cmp_luasnip'

  " Adds LSP completion capabilities
  Plug 'https://github.com/hrsh7th/cmp-nvim-lsp'
  Plug 'https://github.com/hrsh7th/cmp-path'

  " Adds a number of user-friendly snippets
  Plug 'https://github.com/rafamadriz/friendly-snippets'
  " End Autocompletion plugins

  " The `TSUpdate` call tends to throw errors when this is installed. Don't
  " stress, it works on Unix/Linux after the first run. Not worth looking into
  " deeper at the moment.
  Plug 'https://github.com/nvim-treesitter/nvim-treesitter', has('nvim') ? { 'do': ':TSUpdate' } : { 'on': [] }

  " Git related plugins
  Plug 'https://github.com/tpope/vim-fugitive'
  Plug 'https://github.com/tpope/vim-rhubarb'

  " Detect tabstop and shiftwidth automatically
  Plug 'https://github.com/tpope/vim-sleuth'

  " For comment/uncomment support
  Plug 'https://github.com/tpope/vim-commentary'

  " Fuzzy finding stuff
  Plug 'https://github.com/nvim-lua/plenary.nvim'
  Plug 'https://github.com/nvim-telescope/telescope.nvim'
  Plug 'https://github.com/nvim-telescope/telescope-ui-select.nvim'

  " 'ray-x/go.nvim' depends on:
  "   - 'nvim-treesitter/nvim-treesitter'
  "   - 'neovim/nvim-lspconfig
  Plug 'https://github.com/ray-x/go.nvim'

  " recommended for floating window support for the go plugin above
  Plug 'https://github.com/ray-x/guihua.lua'

  " Live preview of markdown file in default browser
  Plug 'https://github.com/iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}

  " Personal fork of a plugin to highlight and modify todo.txt files
  Plug 'https://github.com/eestrada/todo.txt-vim'
endif

" Add local additional plugin inclusions, if any. Use error handling code in
" case no local configs exist. Error handling patterned on code in this link:
" https://www.lua.org/pil/8.4.html
if has('nvim')
  lua << EOF
    local pstatus, perr = pcall(function() require('local_configs.additional_plugins') end)
    if not pstatus then
      vim.notify(string.format('%s', perr), vim.log.levels.ERROR)
    end
EOF
endif

" Any plugin configuration for local plugins should be done in
" $NVIM_CONFIG/after/plugin/local_config.lua

" Close plugin loading AFTER we load local plugin inclusions (if any exist).
call plug#end()

if has('nvim') && exists('g:vscode')
  lua << EOF
    local function vscode_setup()
      local vscode = require('vscode-neovim')

      -- It doesn't seem like the commentary code linked below is necessary anymore
      -- https://github.com/vscode-neovim/vscode-neovim/wiki/Plugins#vim-commentary

      -- Use common keybindings
      vim.keymap.set('n', '[I', function() vscode.call('editor.action.referenceSearch.trigger') end, { desc = 'References' })
      vim.keymap.set('n', 'gr', function() vscode.call('editor.action.referenceSearch.trigger') end,
        { desc = 'Goto references' })

      vim.keymap.set('n', ']d', function() vscode.call('editor.action.marker.next') end,
        { desc = 'Goto next diagnostic message' })

      vim.keymap.set('n', '[d', function() vscode.call('editor.action.marker.prev') end,
        { desc = 'Goto previous diagnostic message' })

      vim.keymap.set('n', '<leader>dl', function() vscode.call('workbench.actions.view.problems') end,
        { desc = 'Open diagnostic location list' })

      -- Act like vim signify and jump between diff changes in editor
      vim.keymap.set('n', ']c', function() vscode.call('workbench.action.editor.nextChange') end,
        { desc = 'Goto next diff change' })

      vim.keymap.set('n', '[c', function() vscode.call('workbench.action.editor.previousChange') end,
        { desc = 'Goto previous diff change' })

      -- Keymaps used by lsp buffers
      vim.keymap.set('n', 'gi', function() vscode.call('editor.action.goToImplementation') end,
        { desc = 'Goto implementation' })

      vim.keymap.set('n', '<space>D', function() vscode.call('editor.action.goToTypeDefinition') end,
        { desc = 'Goto type definition' })

      vim.keymap.set('n', '<leader>rn', function() vscode.call('editor.action.rename') end,
        { desc = '[r]e[n]ame' })

      vim.keymap.set('n', '<space>ca', function() vscode.call('editor.action.sourceAction') end,
        { desc = 'Code action' })

      vim.keymap.set('n', '<space>qf', function() vscode.call('editor.action.quickFix') end,
        { desc = 'Quick fix' })

      -- Add keybindings for telescope tools used often
      vim.keymap.set('n', '<space>sc', function() vscode.call('workbench.action.showCommands') end,
        { desc = '[s]earch [c]ommands' })

      vim.keymap.set('n', '<space>sg', function() vscode.call('workbench.action.findInFiles') end,
        { desc = '[s]earch by [g]repping file contents' })

      vim.keymap.set('n', '<space>sp', function() vscode.call('workbench.action.quickOpenNavigateNextInFilePicker') end,
        { desc = '[s]earch project [p]aths' })
    end

    -- [[ Configure inside VSCode ]]
    local vscode_setup_succeed, vscode_err = pcall(vscode_setup)
    if not vscode_setup_succeed then
      vim.notify(
        string.format('VSCode setup failed. Check nvim config based on errors: %s', vscode_err),
        vim.log.levels.ERROR
      )
    end
EOF
else
  " Only run once Vim has actually loaded
  " Should be safe in both Vim and Neovim, so long as we aren't in vscode
  function s:init() abort
        " [[ Configure vim-signature ]]
        " Use Signature commands if present, otherwise fallback to foolproof default
        if exists(':SignatureListGlobalMarks') > 0
          " List [m]arks that are defined [g]lobally
          nmap <space>mg :SignatureListGlobalMarks<CR>
          " List [m]arks that are defined in current [b]uffer
          nmap <space>mb :SignatureListBufferMarks<CR>
        else
          " List [m]arks that are defined [g]lobally
          nmap <space>mg :marks ABCDEFGHIJKLMNOPQRSTUVWXYZ<CR>:\'
          " List [m]arks that are defined in current [b]uffer
          nmap <space>mb :marks abcdefghijklmnopqrstuvwxyz<CR>:\'
        endif

        " [[ Configure vim-signify ]]
        let g:signify_sign_delete='-'

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
  endfunction

  autocmd VimEnter * call s:init()

  if has('nvim')
    lua << EOF
      -- [[ Utility functions ]]

      -- Shallow copy table contents. nested cloning does not work.
      -- Implementation from here: http://lua-users.org/wiki/CopyTable
      function table.shallowcopy(orig)
        local orig_type = type(orig)
        local copy
        if orig_type == 'table' then
          copy = {}
          for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
          end
        else -- number, string, boolean, etc
          copy = orig
        end
        return copy
      end

      local function download_file(install_path, download_url)
        if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
          vim.fn.system({ 'curl', '-fLo', install_path, '--create-dirs', download_url })
          return true
        else
          return false
        end
      end

      local function ensure_vim_plug()
        local fn = vim.fn

        local install_path = fn.stdpath('data') .. '/site/autoload/plug.vim'
        local vim_plug_url = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
        local bootstrapped = download_file(install_path, vim_plug_url)
        if bootstrapped then
          -- Source it explicitly this first time. Will be autoloaded by neovim on
          -- future startups.
          vim.cmd('source ' .. install_path)
          return true
        else
          return false
        end
      end

      local function load_vim_plug()
        local no_error, bootstrapped = pcall(ensure_vim_plug)
        if no_error then
          -- Module for the [vim-plug plugin manager](https://github.com/junegunn/vim-plug)
          local plug = {}

          -- Indicate whether plug was bootstrapped on this run. i.e. was it
          -- downloaded and sourced on this run of the config.
          plug.Bootstrapped = bootstrapped

          -- Define an individual plugin
          plug.Plug = vim.fn['plug#']

          -- Begin plugin definitions
          plug.Begin = vim.fn['plug#begin']

          -- End plugin definitions
          plug.End = vim.fn['plug#end']

          -- Interactive command(s) that *can* be useful in scripting

          -- Install defined plugins
          function plug.Install() vim.cmd(':PlugInstall') end

          return plug
        else
          return nil
        end
      end

      -- [[ Utility Variables ]]
      local user_home = os.getenv("HOME")

      -- [[ Define functions for plugin setup ]]

      -- [[ Configure lsp ]]
      local function lsp_config_setup()
        -- Setup neovim lua configuration
        -- IMPORTANT: make sure to setup neodev BEFORE lspconfig. See here:
        -- https://github.com/folke/neodev.nvim?tab=readme-ov-file#-setup
        require('neodev').setup()

        -- mason-lspconfig requires that these setup functions are called in this order
        -- before setting up the mason_managed_servers.
        require('mason').setup()
        require('mason-lspconfig').setup()

        local mason_managed_servers = {
          lua_ls = {
            Lua = {
              runtime = {
                -- Tell the language server which version of Lua you're using
                -- (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT'
              },
              workspace = {
                checkThirdParty = false,

                -- pull in all of 'runtimepath'. NOTE: this is slower
                library = vim.api.nvim_get_runtime_file("", true)
              },
              telemetry = { enable = false },
              -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        }

        -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

        -- Ensure the mason_managed_servers above are installed
        local mason_lspconfig = require 'mason-lspconfig'

        mason_lspconfig.setup {
          ensure_installed = vim.tbl_keys(mason_managed_servers),
        }

        mason_lspconfig.setup_handlers {
          function(server_name)
            require('lspconfig')[server_name].setup {
              capabilities = capabilities,
              settings = mason_managed_servers[server_name],
              filetypes = (mason_managed_servers[server_name] or {}).filetypes,
            }
          end,
        }

        -- Using nvim-lspconfig plugin to quickly configure multiple LSPs with sane defaults. See links below.

        local lombok_path = user_home .. "/dev/jdtls/lombok.jar"
        local lombok_dl_url = "https://projectlombok.org/downloads/lombok.jar"
        download_file(lombok_path, lombok_dl_url)

        -- Attempt to download lombok every time before even attaching, otherwise jdtls
        -- won't even start in the first place.
        -- Servers not managed or auto-installed by mason. These language servers will
        -- need to be manually installed, either thru `:Mason` nvim modal, or manually
        -- using system tools.
        local unmanaged_servers = {
          -- for java
          -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#jdtls
          jdtls = {
            cmd = {
              "jdtls",
              -- By using lombok as the Java agent, all definitions are properly loaded, even for lombok generated method definitions.
              "--jvm-arg=-javaagent:" .. lombok_path,
              "-configuration", user_home .. "/.cache/jdtls/config",
              "-data", user_home .. "/.cache/jdtls/workspace"
            },
          },

          -- https://cs.opensource.google/go/x/tools/+/refs/tags/gopls/v0.14.2:gopls/doc/vim.md#neovim
          -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#gopls
          -- Should work so long as `gopls` command is on $PATH
          gopls = {},


          -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#ruby_ls
          ruby_ls = {
            cmd = { 'bundle', 'exec', 'ruby-lsp' },
          },

          -- for ruby
          -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#solargraph
          -- More documentation on using solargraph with bundler:
          -- https://github.com/castwide/solargraph?tab=readme-ov-file#solargraph-and-bundler
          solargraph = {
            cmd = { 'bundle', 'exec', 'solargraph', 'stdio' },
          },

          -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#rubocop
          -- rubocop = {},

          -- for python
          -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#pyright
          pyright = {},

          -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#html
          html = {},

          -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#jsonls
          jsonls = {},

          -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#cssls
          cssls = {},

          -- for typescript/javascript
          -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#tsserver
          tsserver = {},

          -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#yamlls
          yamlls = {},

          -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#lemminx
          lemminx = {
            filetypes = { "xml", "xsd", "xsl", "xslt", "svg", "ant" },
          },

          -- for markdown
          -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#marksman
          marksman = {},

          -- for toml
          -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#taplo
          taplo = {},

          -- for vimscript
          -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#vimls
          vimls = {},
        }

        local lspconfig = require("lspconfig")

        for server_name, opts in pairs(unmanaged_servers) do
          local lopts = table.shallowcopy(opts)
          lopts.capabilities = capabilities
          lspconfig[server_name].setup(lopts)
        end

        -- -- Mainly used for neovim configs, so using the suggested config from link below
        -- -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#lua_ls
        -- -- Should work so long as `lua-language-server` is available on path. See install instruction at link below
        -- -- https://luals.github.io/#neovim-install
        -- lspconfig.lua_ls.setup {
        --   on_init = function(client)
        --     local path = client.workspace_folders[1].name
        --     if not vim.loop.fs_stat(path .. '/.luarc.json') and not vim.loop.fs_stat(path .. '/.luarc.jsonc') then
        --       client.config.settings = vim.tbl_deep_extend('force', client.config.settings, {
        --         Lua = {
        --           runtime = {
        --             -- Tell the language server which version of Lua you're using
        --             -- (most likely LuaJIT in the case of Neovim)
        --             version = 'LuaJIT'
        --           },
        --           -- Make the server aware of Neovim runtime files
        --           workspace = {
        --             checkThirdParty = false,
        --             -- library = {
        --             --   vim.env.VIMRUNTIME
        --             --   -- "${3rd}/luv/library"
        --             --   -- "${3rd}/busted/library",
        --             -- }
        --             -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
        --             library = vim.api.nvim_get_runtime_file("", true)
        --           }
        --         }
        --       })

        --       client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
        --     end
        --     return true
        --   end
        -- }

        -- Other lsp configuration suggestions can be found here:
        -- https://github.com/neovim/nvim-lspconfig/blob/master/README.md#suggested-configuration

        vim.api.nvim_create_autocmd('LspAttach', {
          group = vim.api.nvim_create_augroup('UserLspConfig', { clear = false }),
          callback = function(args)
            local client = vim.lsp.get_client_by_id(args.data.client_id)

            vim.keymap.set('n', '<leader>wa', function() vim.lsp.buf.add_workspace_folder() end,
              { buffer = args.buf, desc = '[w]orkspace [a]dd folder' })
            vim.keymap.set('n', '<leader>wr', function() vim.lsp.buf.remove_workspace_folder() end,
              { buffer = args.buf, desc = '[w]orkspace [r]emove folder' })
            vim.keymap.set('n', '<leader>wl', function() vim.print(vim.lsp.buf.list_workspace_folders()) end,
              { buffer = args.buf, desc = '[w]orkspace [l]ist folders' })

            -- Start of keymaps that shadow existing keymaps
            -- Only redefine uppercase K keymap if current LSP supports hover capability
            vim.keymap.set('n', 'K', function() vim.lsp.buf.hover() end, { buffer = args.buf, desc = 'Hover Popup' })

            -- telescope builtins
            local function definition_func()
              vim.lsp.buf.definition()
              -- require('telescope.builtin').lsp_definitions()(require('telescope.themes').get_ivy({ include_current_line = true }))
            end
            vim.keymap.set('n', '<C-]>', definition_func, { buffer = args.buf, desc = 'Goto Definition' })
            vim.keymap.set('n', 'gd', definition_func, { buffer = args.buf, desc = '[G]oto [D]efinition' })

            -- References
            local function references_func()
              vim.lsp.buf.references()
              -- require('telescope.builtin').lsp_references(require('telescope.themes').get_ivy({ include_current_line = true }))
            end
            vim.keymap.set('n', 'gH', references_func, { buffer = args.buf, desc = '[G]oto [R]eferences' })
            vim.keymap.set('n', 'gr', references_func, { buffer = args.buf, desc = '[G]oto [R]eferences' })
            vim.keymap.set('n', '[I', references_func, { buffer = args.buf, desc = 'References' })

            local function implementation_func()
              vim.lsp.buf.implementation()
              -- require('telescope.builtin').lsp_implementations(require('telescope.themes').get_ivy({}))
            end
            vim.keymap.set('n', 'gi', implementation_func, { buffer = args.buf, desc = '[G]oto [I]mplementation' })

            local function type_definition_func()
              vim.lsp.buf.type_definition()
              -- require('telescope.builtin').lsp_type_definitions(require('telescope.themes').get_ivy({}))
            end
            vim.keymap.set('n', '<leader>D', type_definition_func, { buffer = args.buf, desc = 'Type [D]efinition' })

            local function document_symbols_func()
              -- vim.lsp.buf.document_symbol()
              require('telescope.builtin').lsp_document_symbols()
            end
            vim.keymap.set('n', '<leader>ds', document_symbols_func, { buffer = args.buf, desc = '[D]ocument [S]ymbols' })

            vim.keymap.set('n', '<leader>ws', function() require('telescope.builtin').lsp_dynamic_workspace_symbols() end,
              { buffer = args.buf, desc = '[W]orkspace [S]ymbols' })
            vim.keymap.set('n', 'gD', function() vim.lsp.buf.declaration() end,
              { buffer = args.buf, desc = 'Goto declaration' })

            vim.keymap.set('n', '<C-k>',
              function() vim.lsp.buf.signature_help() end,
              { buffer = args.buf, desc = 'Signature help' }
            )

            -- custom keymaps using <leader> key
            vim.keymap.set('n', '<leader>rn', function() vim.lsp.buf.rename() end, { buffer = args.buf, desc = '[r]e[n]ame' })

            vim.keymap.set({ 'n', 'v' }, '<leader>ca',
              function() vim.lsp.buf.code_action() end,
              { buffer = args.buf, desc = '[c]ode [a]ction' }
            )

            -- This is something different in vscode, but we duplicate it here so that it actually points to something
            vim.keymap.set({ 'n', 'v' }, '<leader>qf',
              function() vim.lsp.buf.code_action() end,
              { buffer = args.buf, desc = '[q]uick [f]ix (i.e. Code Action)' }
            )

            vim.keymap.set({ 'n', 'v' }, '<leader>fb',
              function() vim.lsp.buf.format() end,
              { buffer = args.buf, desc = '[f]ormat [b]uffer' }
            )

            -- foldingRangeProvider
            if client.server_capabilities.documentHighlightProvider then
              vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                pattern = '<buffer>',
                callback = function()
                  vim.lsp.buf.document_highlight()
                end
              })
              vim.api.nvim_create_autocmd('CursorMoved', {
                pattern = '<buffer>',
                callback = function()
                  vim.lsp.buf.clear_references()
                end
              })
            end
          end,
        })
      end

      -- [[ Configure go ]]
      local function go_setup()
        local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
        vim.api.nvim_create_autocmd("BufWritePre", {
          pattern = "*.go",
          callback = function()
            require('go.format').goimport()
          end,
          group = format_sync_grp,
        })

        require("go").setup()
      end

      -- [[ Configure nvim-cmp ]]
      -- See `:help cmp`
      local function cmp_setup()
        local cmp = require 'cmp'
        local luasnip = require 'luasnip'
        require('luasnip.loaders.from_vscode').lazy_load()
        require('luasnip.loaders.from_vscode').lazy_load()
        luasnip.config.setup {}

        cmp.setup {
          snippet = {
            expand = function(args)
              luasnip.lsp_expand(args.body)
            end,
          },
          completion = {
            completeopt = 'menu,menuone,noinsert',
          },
          mapping = cmp.mapping.preset.insert {
            ['<C-n>'] = cmp.mapping.select_next_item(),
            ['<C-p>'] = cmp.mapping.select_prev_item(),
            ['<C-b>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete {},
            ['<CR>'] = cmp.mapping.confirm {
              behavior = cmp.ConfirmBehavior.Replace,
              select = true,
            },
            ['<Tab>'] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              elseif luasnip.expand_or_locally_jumpable() then
                luasnip.expand_or_jump()
              else
                fallback()
              end
            end, { 'i', 's' }),
            ['<S-Tab>'] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              elseif luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
              else
                fallback()
              end
            end, { 'i', 's' }),
          },
          sources = {
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
            { name = 'path' },
          },
        }
      end

      -- [[ Configure fidget ]]
      local function fidget_setup()
        require("fidget").setup({
          -- Options related to LSP progress subsystem
          progress = {
            -- Options related to how LSP progress messages are displayed as notifications
            display = {
              skip_history = false, -- Whether progress notifications should be omitted from history
            },
          },
        })
      end

      -- [[ Configure telescope ]]
      local function telescope_setup()
        -- use 'nvim-telescope/telescope-ui-select.nvim' for ui selection picker
        -- See config here: https://github.com/nvim-telescope/telescope-ui-select.nvim?tab=readme-ov-file#telescope-setup-and-configuration
        -- This is your opts table
        require("telescope").setup {
          extensions = {
            ["ui-select"] = {
              require("telescope.themes").get_dropdown {
                -- even more opts
              }

              -- pseudo code / specification for writing custom displays, like the one
              -- for "codeactions"
              -- specific_opts = {
              --   [kind] = {
              --     make_indexed = function(items) -> indexed_items, width,
              --     make_displayer = function(widths) -> displayer
              --     make_display = function(displayer) -> function(e)
              --     make_ordinal = function(e) -> string
              --   },
              --   -- for example to disable the custom builtin "codeactions" display
              --      do the following
              --   codeactions = false,
              -- }
            }
          }
        }
        -- To get ui-select loaded and working with telescope, you need to call
        -- load_extension, somewhere after setup function:
        require("telescope").load_extension("ui-select")

        -- Fuzzy keymaps
        -- Also Telescope is much, MUCH slower than fzf, fzf is uglier and requires an external binary.
        vim.keymap.set('n', '<leader>st', ':Telescope<CR>', { desc = '[s]earch [t]elescope builtin commands lists' })
        vim.keymap.set('n', '<leader>sb', ':Telescope buffers<CR>', { desc = '[s]earch [b]uffers' })
        vim.keymap.set('n', '<leader>sc', ':Telescope commands<CR>', { desc = '[s]earch [c]ommands' })
        vim.keymap.set('n', '<leader>sg', ':Telescope live_grep<CR>', { desc = '[s]earch with [g]rep' })
        vim.keymap.set('n', '<leader>sh', ':Telescope help_tags<CR>', { desc = '[s]earch [h]elp tags' })
        vim.keymap.set('n', '<leader>sk', ':Telescope keymaps<CR>', { desc = '[s]earch [k]eymaps' })
        vim.keymap.set('n', '<leader>sp', ':Telescope find_files<CR>', { desc = '[s]earch project [p]aths' })
        vim.keymap.set('n', '<leader>so', ':Telescope oldfiles<CR>', { desc = '[s]earch [o]ld files opened previously' })
        vim.keymap.set('n', '<leader>sv', ':Telescope git_files<CR>', { desc = '[s]earch [v]ersion controlled file paths' })
      end

      local function treesitter_setup()
        require 'nvim-treesitter.configs'.setup {
          modules = {},        -- Added to silence linter
          ignore_install = {}, -- Added to silence linter

          -- A list of parser names, or "all" (the five listed parsers should always be installed)
          ensure_installed = { "lua", "vim", "vimdoc", "query" },

          -- Install parsers synchronously (only applied to `ensure_installed`)
          sync_install = false,

          -- Automatically install missing parsers when entering buffer
          -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
          auto_install = true,

          ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
          -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

          highlight = {
            enable = true,

            -- use a function to disable slow treesitter highlight for large files
            disable = function(lang, buf)
              local max_filesize = 100 * 1024 -- 100 KB
              local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
              if ok and stats and stats.size > max_filesize then
                return true
              end
            end,

            -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
            -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
            -- Using this option may slow down your editor, and you may see some duplicate highlights.
            -- Instead of true it can also be a list of languages
            additional_vim_regex_highlighting = false,
          },
        }

        local parser_config = require('nvim-treesitter.parsers').get_parser_configs()

        parser_config.gotmpl = {
          install_info = {
            url = "https://github.com/ngalaiko/tree-sitter-go-template",
            files = { "src/parser.c" }
          },
          filetype = "gotmpl",
          used_by = { "gohtmltmpl", "gotexttmpl", "gotmpl" }
        }
      end


      -- [[ configurations in functions ]]
      local msg = '%s load/setup failed. Try installing plugins and reloading nvim'

      -- local init_funcs = {
      --   fidget = fidget_setup,
      --   golang = go_setup,
      --   ['lsp config'] = lsp_config_setup,
      --   ['cmp and luasnip'] = cmp_setup,
      --   telescope = telescope_setup,
      --   treesitter = treesitter_setup,
      -- }

      -- for setup_name, setup_func in pairs(init_funcs) do
      --   local setup_succeed, setup_err = pcall(setup_func)
      --   if not setup_succeed then
      --     vim.notify(
      --       string.format('%s setup failed. Check nvim config based on errors: %s', setup_name, setup_err),
      --       vim.log.levels.ERROR
      --     )
      --   end
      -- end

      if not pcall(fidget_setup) then
        vim.notify(string.format(msg, 'fidget'), vim.log.levels.ERROR)
      end

      if not pcall(go_setup) then
        vim.notify(string.format(msg, 'golang'), vim.log.levels.ERROR)
      end

      if not pcall(lsp_config_setup) then
        vim.notify(string.format(msg, 'lsp config'), vim.log.levels.ERROR)
      end

      if not pcall(cmp_setup) then
        vim.notify(string.format(msg, 'cmp and luasnip'), vim.log.levels.ERROR)
      end

      if not pcall(telescope_setup) then
        vim.notify(string.format(msg, 'telescope'), vim.log.levels.ERROR)
      end

      if not pcall(treesitter_setup) then
        vim.notify(string.format(msg, 'treesitter'), vim.log.levels.ERROR)
      end
EOF
  endif
endif
