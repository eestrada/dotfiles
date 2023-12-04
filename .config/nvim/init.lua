-- General vi/vim/neovim options to work like I want, regardless of keymaps or LSPs
require('options')

-- Configure desired plugins
local Plug = vim.fn['plug#']
vim.call('plug#begin')

Plug('https://github.com/neovim/nvim-lspconfig')

vim.call('plug#end')

-- Configure LSPs for all languages I care about
require('lsp_configs')

-- Add local configuration files, if any
-- Use error handling code in case no local configs exist
-- Error handling patterned after code this link: https://www.lua.org/pil/8.4.html
local status, err = pcall(function () require('local_configs') end)
if status then
  -- no errors while requiring local configs
  print('Successfully loaded local configurations')
else
  -- requiring local configs raised an error
  print('Could not load local configuration files')
  -- print(err)
end

