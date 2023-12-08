-- Don't create swapfiles by default
vim.opt.uc = 0

-- Syntax settings
vim.opt.background = 'dark'
-- Make sure syntax highlighting is on for supported file types.
vim.cmd('syntax enable')
vim.cmd('colorscheme desert')
-- turn on special character highlighting
vim.opt.list = true
-- define what special characters look like
vim.opt.listchars = { trail = '·', tab = '»-', eol = '¬' }

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
vim.opt.colorcolumn = {"80"}

-- Always use the system clipboard for all yank/paste operations. See link
-- below for details.
-- https://neovim.io/doc/user/provider.html#provider-clipboard
vim.cmd('set clipboard+=unnamedplus')
