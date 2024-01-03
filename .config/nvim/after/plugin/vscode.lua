if not vim.g.vscode then
  return
end

local vscode = require('vscode-neovim')

-- It doesn't seem like the commentary code linked below is necessary anymore
-- https://github.com/vscode-neovim/vscode-neovim/wiki/Plugins#vim-commentary

-- Use common keybindings
vim.keymap.set('n', '[I', function() vscode.call('editor.action.referenceSearch.trigger') end, { desc = 'References' })
vim.keymap.set('n', 'gr', function() vscode.call('editor.action.referenceSearch.trigger') end,
  { desc = 'Goto references' })

vim.keymap.set('n', ']d', function() vscode.call('editor.action.marker.next') end,
  { desc = 'Goto next diagnostic message' })

vim.keymap.set('n', '[d', function() vscode.call('editor.action.marker.prev') end,
  { desc = 'Goto previous diagnostic message' })

vim.keymap.set('n', '<leader>dl', function() vscode.call('workbench.actions.view.problems') end,
  { desc = 'Open diagnostic location list' })

-- Act like vim signify and jump between diff changes in editor
vim.keymap.set('n', ']c', function() vscode.call('workbench.action.editor.nextChange') end,
  { desc = 'Goto next diff change' })

vim.keymap.set('n', '[c', function() vscode.call('workbench.action.editor.previousChange') end,
  { desc = 'Goto previous diff change' })

-- Keymaps used by lsp buffers
vim.keymap.set('n', 'gi', function() vscode.call('editor.action.goToImplementation') end,
  { desc = 'Goto implementation' })

vim.keymap.set('n', '<space>D', function() vscode.call('editor.action.goToTypeDefinition') end,
  { desc = 'Goto type definition' })

vim.keymap.set('n', '<leader>rn', function() vscode.call('editor.action.rename') end,
  { desc = '[r]e[n]ame' })

vim.keymap.set('n', '<space>ca', function() vscode.call('editor.action.sourceAction') end,
  { desc = 'Code action' })

vim.keymap.set('n', '<space>qf', function() vscode.call('editor.action.quickFix') end,
  { desc = 'Quick fix' })

-- Add keybindings for telescope tools used often
vim.keymap.set('n', '<space>sc', function() vscode.call('workbench.action.showCommands') end,
  { desc = '[s]earch [c]ommands' })

vim.keymap.set('n', '<space>sg', function() vscode.call('workbench.action.findInFiles') end,
  { desc = '[s]earch by [g]repping file contents' })

vim.keymap.set('n', '<space>sp', function() vscode.call('workbench.action.quickOpenNavigateNextInFilePicker') end,
  { desc = '[s]earch project [p]aths' })
