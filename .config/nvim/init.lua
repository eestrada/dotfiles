-- General vi/vim/neovim options to work like I want, regardless of keymaps,
-- LSPs, or plugins.
require('myconfigs.options')
require('myconfigs.keymappings')
require('myconfigs.commands')

local plug = require('bootstrap.plug')

-- Configure desired plugins
plug.Begin()

plug.Plug('https://github.com/junegunn/fzf', { ['do'] = function() vim.call('fzf#install()') end })
plug.Plug('https://github.com/junegunn/fzf.vim')
plug.Plug('https://github.com/mhinz/vim-signify')
plug.Plug('https://github.com/neovim/nvim-lspconfig')

-- The `TSUpdate` call tends to throw errors when this is installed. Don't
-- stress, it works after the first run. Not worth looking into deeper at the
-- moment.
plug.Plug('https://github.com/nvim-treesitter/nvim-treesitter', { ['do'] = function() vim.cmd('TSUpdate') end })
plug.Plug('https://github.com/tpope/vim-fugitive')
plug.Plug("https://github.com/nvim-lua/plenary.nvim")
plug.Plug("https://github.com/nvim-telescope/telescope.nvim")
plug.Plug('https://github.com/ray-x/go.nvim')

-- recommended for floating window support for the go plugin above
plug.Plug('https://github.com/ray-x/guihua.lua')

-- Add local additional plugin inclusions, if any. Use error handling code in
-- case no local configs exist. Error handling patterned after code this link:
-- https://www.lua.org/pil/8.4.html
local local_configs_dir = vim.fn.stdpath('config') .. '/lua/local_configs'
local pstatus, perr = pcall(function() require('local_configs.additional_plugins') end)
if pstatus then
  -- print('Loaded local additional plugin inclusions')
else
  print(perr)
  vim.fn.mkdir(local_configs_dir, "p")
  local additional_plugins_path = local_configs_dir .. '/additional_plugins.lua'
  local file = io.open(additional_plugins_path, "w")
  if file ~= nil then
    file:close()
    print('Created placeholder local_config/additional_plugins.lua init to silence this error in future calls to nvim')
  end
end

-- Close plugin loading AFTER we local plugin inclusions (if then exist).
plug.End()

if plug.Bootstrapped then
  -- Installed all defined plugins. Will leave a pop up window with a report
  -- of installed plugins.
  plug.Install()
end

-- Get local configs after plugins have been defined and hopefully loaded
local status, err = pcall(function() require('local_configs') end)
if status then
  --print('Loaded local configs')
else
  print(err)
  vim.fn.mkdir(local_configs_dir, "p")
  local local_configs_init = local_configs_dir .. '/init.lua'
  local file = io.open(local_configs_init, "w")
  if file ~= nil then
    file:close()
    print('Created placeholder local_config/init.lua to silence this error in future calls to nvim')
  end
end

