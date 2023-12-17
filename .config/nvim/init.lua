-- General vi/vim/neovim options to work like I want, regardless of LSPs,
-- plugins, or  keymaps for LSPs/plugins.

-- Start OPTIONS
-- Don't create swapfiles by default
vim.opt.uc = 0

-- Syntax settings
-- Dark background
vim.opt.background = 'dark'
-- Make sure syntax highlighting is on for supported file types.
vim.cmd('syntax enable')
-- Set colorscheme
vim.cmd('colorscheme desert')
-- turn on special character highlighting
vim.opt.list = true
-- define what special characters look like
vim.opt.listchars = { trail = '~', tab = '>-', eol = '$' }
-- Do not ring the bell for error messages.
vim.opt.errorbells = false
-- Use visual bell instead of beeping.
vim.opt.visualbell = true
-- Never wrap long lines.
vim.opt.wrap = false
-- When there is a search pattern, do no highlight all matches.
vim.opt.hlsearch = false
-- Incremental search highlight. Useful for constructing regexes.
vim.opt.incsearch = true
-- Show line and column number.
vim.opt.ruler = true
-- Print the line number in front of each line.
vim.opt.number = true
-- Minimal number of columns to use for the line number.
vim.opt.numberwidth = 4

-- Indentation and Tab Settings
-- Copy indent from current line when starting a new line.
vim.opt.autoindent = true
-- Use indent rules based on current filetype.
vim.opt.smartindent = true
-- Default to using spaces when hiting <Tab> key.
vim.opt.expandtab = true
-- Number of spaces that a <Tab> counts for while editing.
vim.opt.softtabstop = 4
-- Number of spaces that a true <Tab> in the file renders as.
vim.opt.tabstop = 4
-- Number of spaces to use for each step of (auto)indent. Zero means "same as
-- tabstop".
vim.opt.shiftwidth = 0

-- At least 8 line visible buffer when moving up/down file.
vim.opt.scrolloff = 8
-- show sign column even when empty
vim.opt.signcolumn = "yes"
-- fast update time
vim.opt.updatetime = 50
-- visual line column(s)
vim.opt.colorcolumn = { "80" }
-- Always use the system clipboard for all yank/paste operations. See link
-- below for details.
-- https://neovim.io/doc/user/provider.html#provider-clipboard
vim.cmd('set clipboard+=unnamedplus')
-- End OPTIONS

-- Start GLOBAL_VARIABLES
vim.g.mapleader = " "

-- Neovim will use `xdg-open` by default. WSL2 will set this to something that
-- can be opened in Windows directly. No special config is necessary here, just
-- make sure to install xdg-open and neovim will do the right thing.
-- https://superuser.com/a/1687625/474473
--
-- If things are really bad and that doesn't work, set g:netrw_browsex_viewer,
-- like mentioned below. You can use `sensible-browser` on debian based
-- systems. Or you can install and use `wslview`. However, all of these things
-- should not be necessary if `xdg-open` is available.
-- * https://neovim.io/doc/user/pi_netrw.html#netrw_filehandler

-- End GLOBAL_VARIABLES

-- Start KEYMAPS
vim.keymap.set('n', '<leader>e', ':Ex<CR>', { desc = '[E]xplore files with netrw' })
-- End KEYMAPS

-- Start COMMANDS
-- My custom defined commands
vim.api.nvim_create_user_command(
  'StripTrailingWS',
  [[%s/\s\+$//e]],
  {
    desc = 'Strip all trailing whitespace on lines of current document'
  }
)
-- End COMMANDS

-- Start VSCODE config
-- See docs here: https://github.com/vscode-neovim/vscode-neovim
if vim.g.vscode then
  local vscode = require('vscode-neovim')
  vim.notify = vscode.notify
end

-- End VSCODE config

local local_configs_dir = vim.fn.stdpath('config') .. '/lua/local_configs'

if pcall(function() require('bootstrap.plug') end) then
  local plug = require('bootstrap.plug')

  -- Configure desired plugins
  plug.Begin()

  if not vim.g.vscode then
    plug.Plug(
      'https://github.com/junegunn/fzf',
      { ['do'] = function() vim.call('fzf#install()') end }
    )
    plug.Plug('https://github.com/junegunn/fzf.vim')
    plug.Plug('https://github.com/mhinz/vim-signify')
    plug.Plug('https://github.com/neovim/nvim-lspconfig')

    -- The `TSUpdate` call tends to throw errors when this is installed. Don't
    -- stress, it works on Unix/Linux after the first run. Not worth looking into
    -- deeper at the moment.
    plug.Plug(
      'https://github.com/nvim-treesitter/nvim-treesitter',
      { ['do'] = function() vim.cmd('TSUpdate') end }
    )
    plug.Plug('https://github.com/tpope/vim-fugitive')
    plug.Plug('https://github.com/nvim-lua/plenary.nvim')
    plug.Plug('https://github.com/nvim-telescope/telescope.nvim')

    -- 'ray-x/go.nvim' depends on:
    --   - 'nvim-treesitter/nvim-treesitter'
    --   - 'neovim/nvim-lspconfig
    plug.Plug('https://github.com/ray-x/go.nvim')

    -- recommended for floating window support for the go plugin above
    plug.Plug('https://github.com/ray-x/guihua.lua')

    -- For comment/uncomment support
    plug.Plug('https://github.com/tpope/vim-commentary')
  end

  -- Add local additional plugin inclusions, if any. Use error handling code in
  -- case no local configs exist. Error handling patterned on code in this link:
  -- https://www.lua.org/pil/8.4.html
  local pstatus, perr = pcall(function() require('local_configs.additional_plugins') end)
  if not pstatus then
    vim.notify(string.format('%s', perr), vim.log.levels.ERROR)
  end

  -- Close plugin loading AFTER we local plugin inclusions (if then exist).
  plug.End()

  if plug.Bootstrapped then
    -- Installed all defined plugins. Will leave a pop up window with a report
    -- of installed plugins.
    plug.Install()
  end
end

-- Get local configs after plugins have been defined and hopefully loaded
local status, err = pcall(function() require('local_configs') end)
if not status then
  vim.notify(string.format('%s', err), vim.log.levels.ERROR)
end
