-- Don't create swapfiles by default
vim.opt.uc = 0

-- Syntax settings
vim.opt.background = 'dark'
vim.cmd('syntax enable') -- Make sure syntax highlighting is on for supported file types.
vim.cmd('colorscheme desert')
vim.opt.list = true -- turn on special character highlighting
vim.opt.listchars = { trail = '·', tab = '»-', eol = '¬' } -- define what special characters look like

vim.opt.autoindent = true -- Copy indent from current line when starting a new line.
vim.opt.shiftwidth = 4 -- Number of spaces to use for each step of (auto)indent.
vim.opt.errorbells = false -- Do not ring the bell for error messages.
vim.opt.visualbell = true -- Use visual bell instead of beeping.

-- set wrap -- Lines longer than the width of the window will wrap.
vim.opt.wrap = false -- Never wrap long lines.

vim.opt.hlsearch = true -- When there is a search pattern, highlight all matches.
vim.opt.ruler = true -- Show line and column number.
vim.opt.number = true -- Print the line number in front of each line.
vim.opt.numberwidth = 4 -- Minimal number of columns to use for the line number.

-- Does not work in lua in this form
-- vim.opt.backspace = 2 -- make backspace work like most other apps

-- Tab Settings
-- set expandtab -- Use the appropriate number of spaces to insert a	<Tab>.
vim.opt.expandtab = false -- Messes up Makefiles and stuff. Just hit spacebar a few extra times.
vim.opt.softtabstop = 4 -- Number of spaces that a <Tab> counts for while editing.
vim.opt.tabstop = 4 -- Number of spaces that a <Tab> in the file counts for.

-- Will need to be refactored to work in Lua
-- -- System friendly settings
-- -- Using system clipboard pulled from: http://vimcasts.org/episodes/accessing-the-system-clipboard-from-vim/
-- -- Use system clipboard for Yank and Put
-- set clipboard=unnamed
-- if has('unnamedplus')
--     -- Use system AND xterm clipboards for Yank and Put
--     set clipboard=unnamed,unnamedplus
-- endif

-- Will need to be refactored to work in Lua
-- Delete Trailing whitespace
--  Autocmd pulled from:
--  http://vim.wikia.com/wiki/Remove_unwanted_spaces#Automatically_removing_all_trailing_whitespace
-- autocmd BufWritePre * %s/\s\+$//e

-- Search in visual mode
-- vnoremap <expr> // 'y/\V'.escape(@",'\').'<CR>'

