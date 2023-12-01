-- Don't create swapfiles by default
vim.opt.uc = 0

-- Syntax settings
vim.opt.background = 'dark'
vim.cmd('syntax enable') -- Make sure syntax highlighting is on for supported file types.
vim.cmd('colorscheme desert')
vim.opt.list = true -- turn on special character highlighting
vim.opt.listchars = { trail = '·', tab = '»-', eol = '¬' } -- define what special characters look like

vim.opt.errorbells = false -- Do not ring the bell for error messages.
vim.opt.visualbell = true -- Use visual bell instead of beeping.

-- set wrap -- Lines longer than the width of the window will wrap.
vim.opt.wrap = false -- Never wrap long lines.

vim.opt.hlsearch = true -- When there is a search pattern, highlight all matches.
vim.opt.ruler = true -- Show line and column number.
vim.opt.number = true -- Print the line number in front of each line.
vim.opt.numberwidth = 4 -- Minimal number of columns to use for the line number.

-- Indentation and Tab Settings
vim.opt.autoindent = true -- Copy indent from current line when starting a new line.
vim.opt.smartindent = true -- Use indent rules based on current filetype.
vim.opt.expandtab = true -- Default to using spaces when hiting <Tab> key.
vim.opt.softtabstop = 4 -- Number of spaces that a <Tab> counts for while editing.
vim.opt.tabstop = 4 -- Number of spaces that a true <Tab> in the file renders as.
vim.opt.shiftwidth = 0 -- Number of spaces to use for each step of (auto)indent. Zero means "same as tabstop".

-- Always use the system clipboard for all yank/paste operations. See link below for details.
-- https://neovim.io/doc/user/provider.html#provider-clipboard
vim.cmd('set clipboard+=unnamedplus')

-- Will need to be refactored to work in Lua
-- Delete Trailing whitespace
--  Autocmd pulled from:
--  http://vim.wikia.com/wiki/Remove_unwanted_spaces#Automatically_removing_all_trailing_whitespace
-- autocmd BufWritePre * %s/\s\+$//e

-- Search in visual mode
-- vnoremap <expr> // 'y/\V'.escape(@",'\').'<CR>'

