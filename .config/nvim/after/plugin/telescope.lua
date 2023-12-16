if vim.g.vscode then
  return
end

-- Fuzzy keymaps
-- Telescope is much, MUCH slower than fzf, so use fzf for nearly everything else.
vim.keymap.set('n', '<leader>ft', ':Telescope<CR>', { desc = '[F]uzzy search [T]elescope lists' })

-- Keymap search is broken in fzf for some reason. Use telescope instead.
vim.keymap.set('n', '<leader>fk', ':Telescope keymaps<CR>', { desc = '[F]uzzy search [K]eymaps' })

-- Colors buffer contents
vim.keymap.set('n', '<leader>fb', ':Telescope buffers<CR>', { desc = '[F]uzzy search [B]uffers' })
-- vim.keymap.set('n', '<leader>fp', ':Telescope old_files<CR>', { desc = '[F]uzzy search project [P]aths' })
-- vim.keymap.set('n', '<leader>fv', ':Telescope git_files<CR>', { desc = '[F]uzzy search [V]ersion controlled file paths' })
-- vim.keymap.set('n', '<leader>fc', ':Telescope commands<CR>', { desc = '[F]uzzy search [C]ommands' })
