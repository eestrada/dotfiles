require('options')

local Plug = vim.fn['plug#']
vim.call('plug#begin')

Plug('https://github.com/neovim/nvim-lspconfig')

vim.call('plug#end')

-- Based on info in link below:
-- https://cs.opensource.google/go/x/tools/+/refs/tags/gopls/v0.14.2:gopls/doc/vim.md#neovim
local lspconfig = require("lspconfig")

-- Should work so long as `gopls` command is on $PATH
lspconfig.gopls.setup({})

-- lsp configuration suggestions can be found here:
-- https://github.com/neovim/nvim-lspconfig/blob/master/README.md
