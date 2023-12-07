-- General vi/vim/neovim options to work like I want, regardless of keymaps,
-- LSPs, or plugins.
require('options')

vim.g.mapleader = " "

-- Configure desired plugins
local Plug = vim.fn['plug#']
vim.call('plug#begin')

Plug('https://github.com/junegunn/fzf', { ['do'] = function() vim.call('fzf#install()') end })
Plug('https://github.com/junegunn/fzf.vim')
Plug('https://github.com/mhinz/vim-signify')
Plug('https://github.com/neovim/nvim-lspconfig')

-- Add local additional plugin inclusions, if any. Use error handling code in
-- case no local configs exist. Error handling patterned after code this link:
-- https://www.lua.org/pil/8.4.html
local pstatus, perr = pcall(function() require('local_configs/additional_plugins') end)
if pstatus then
    -- print('Loaded local additional plugin inclusions')
else
    print(perr)
end

-- Close plugin loading AFTER we load plugin inclusions.
vim.call('plug#end')

-- Get local configs after plugins have been defined and hopefully loaded
local status, err = pcall(function() require('local_configs') end)
if status then
    --print('Loaded local configs')
else
    print(err)
end

-- Configure LSPs for all languages I care about
require('lsp_configs')
require('keymappings')

vim.g.signify_sign_delete = '-'

-- I'm still on the fence on whether or not I want to show the count of deleted
-- lines in the gutter.
-- vim.g.signify_sign_show_count = false

