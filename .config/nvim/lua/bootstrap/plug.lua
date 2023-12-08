local ensure_vim_plug = function()
  local fn = vim.fn

  local install_path = fn.stdpath('data') .. '/site/autoload/plug.vim'
  if fn.empty(fn.glob(install_path)) > 0 then
    local vim_plug_url = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    fn.system({ 'curl', '-fLo', install_path, '--create-dirs', vim_plug_url })
    -- Source it explicitly this first time. Will be autoloaded by neovim on
    -- future startups.
    vim.cmd('source ' .. install_path)
    return true
  else
    return false
  end
end

local plug_module = {}
plug_module.Bootstrapped = ensure_vim_plug()

-- For scripting
plug_module.Plug = vim.fn['plug#']
plug_module.Begin = vim.fn['plug#begin']
plug_module.End = vim.fn['plug#end']

-- Mostly interactive commands that *can* be useful in scripting
plug_module.Clean = function() vim.cmd(':PlugClean') end
plug_module.Diff = function() vim.cmd(':PlugDiff') end
plug_module.Install = function() vim.cmd(':PlugInstall') end
plug_module.Snapshot = function() vim.cmd(':PlugSnapshot') end
plug_module.Status = function() vim.cmd(':PlugStatus') end
plug_module.Update = function() vim.cmd(':PlugUpdate') end
plug_module.Upgrade = function() vim.cmd(':PlugUpgrade') end

return plug_module
