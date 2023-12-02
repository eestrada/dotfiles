require('options')

-- Only works if lsp plugin has been installed
vim.cmd('packadd lspconfig')

-- Based on info in link below:
-- https://cs.opensource.google/go/x/tools/+/refs/tags/gopls/v0.14.2:gopls/doc/vim.md#neovim
local lspconfig = require("lspconfig")
lspconfig.gopls.setup({})

-- lsp configuration suggestions can be found here:
-- https://github.com/neovim/nvim-lspconfig/blob/master/README.md
