local utils = require('bootstrap.utils')

local M = {}

M.Bootstrapped = utils.download_file(
  vim.fn.stdpath('data') .. '/site/autoload/plug.vim',
  'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
)

-- For scripting
M.Plug = vim.fn['plug#']
M.Begin = vim.fn['plug#begin']
M.End = vim.fn['plug#end']

-- Mostly interactive commands that *can* be useful in scripting
M.Clean = function() vim.cmd(':PlugClean') end
M.Diff = function() vim.cmd(':PlugDiff') end
M.Install = function() vim.cmd(':PlugInstall') end
M.Snapshot = function() vim.cmd(':PlugSnapshot') end
M.Status = function() vim.cmd(':PlugStatus') end
M.Update = function() vim.cmd(':PlugUpdate') end
M.Upgrade = function() vim.cmd(':PlugUpgrade') end

return M
