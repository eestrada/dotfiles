-- The leader key isn't truly a keymap, but it's related
vim.g.mapleader = " "

vim.keymap.set('n', '<leader>e', ':Ex<CR>', { desc = '[E]xplore files with netrw' })

