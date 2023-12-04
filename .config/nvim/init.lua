-- General vi/vim/neovim options to work like I want, regardless of keymaps or LSPs
require('options')

-- Configure desired plugins
local Plug = vim.fn['plug#']
vim.call('plug#begin')

Plug('https://github.com/neovim/nvim-lspconfig')

vim.call('plug#end')

-- Configure LSPs for all languages I care about
require('lsp_configs')

