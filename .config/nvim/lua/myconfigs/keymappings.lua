-- The leader key isn't truly a keymap, but it's related
vim.g.mapleader = " "

-- Fuzzy keymaps
vim.keymap.set('n', '<leader>fp', ':Files<CR>', { desc = '[F]uzzy search project [P]aths' })
vim.keymap.set('n', '<leader>fv', ':GitFiles<CR>', { desc = '[F]uzzy search [V]ersion controlled file paths' })
vim.keymap.set('n', '<leader>fc', ':Commands<CR>', { desc = '[F]uzzy search [C]ommands' })
vim.keymap.set('n', '<leader>fs', ':Snippets<CR>', { desc = '[F]uzzy search [S]nippets' })
vim.keymap.set('n', '<leader>fb', ':Buffers<CR>', { desc = '[F]uzzy search [B]uffers' })
vim.keymap.set('n', '<leader>fg', ':Rg<CR>', { desc = '[F]uzzy [G]rep files' })

