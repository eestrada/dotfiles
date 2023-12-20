if vim.g.vscode then
  return
end

-- use 'nvim-telescope/telescope-ui-select.nvim' for ui selection picker
-- See config here: https://github.com/nvim-telescope/telescope-ui-select.nvim?tab=readme-ov-file#telescope-setup-and-configuration
-- This is your opts table
require("telescope").setup {
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_dropdown {
        -- even more opts
      }

      -- pseudo code / specification for writing custom displays, like the one
      -- for "codeactions"
      -- specific_opts = {
      --   [kind] = {
      --     make_indexed = function(items) -> indexed_items, width,
      --     make_displayer = function(widths) -> displayer
      --     make_display = function(displayer) -> function(e)
      --     make_ordinal = function(e) -> string
      --   },
      --   -- for example to disable the custom builtin "codeactions" display
      --      do the following
      --   codeactions = false,
      -- }
    }
  }
}
-- To get ui-select loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
require("telescope").load_extension("ui-select")

-- Fuzzy keymaps
-- Also Telescope is much, MUCH slower than fzf, fzf is uglier and requires an external binary.
vim.keymap.set('n', '<leader>ft', ':Telescope<CR>', { desc = '[f]uzzy search [t]elescope lists' })

vim.keymap.set('n', '<leader>fb', ':Telescope buffers<CR>', { desc = '[f]uzzy search [b]uffers' })
vim.keymap.set('n', '<leader>fc', ':Telescope commands<CR>', { desc = '[f]uzzy search [c]ommands' })
vim.keymap.set('n', '<leader>fg', ':Telescope live_grep<CR>', { desc = '[f]uzzy [g]rep' })
vim.keymap.set('n', '<leader>fh', ':Telescope help_tags<CR>', { desc = '[f]uzzy search [h]elp tags' })
vim.keymap.set('n', '<leader>fk', ':Telescope keymaps<CR>', { desc = '[F]uzzy search [K]eymaps' })
vim.keymap.set('n', '<leader>fp', ':Telescope find_files<CR>', { desc = '[f]uzzy search project [p]aths' })
vim.keymap.set('n', '<leader>fv', ':Telescope git_files<CR>', { desc = '[f]uzzy search [v]ersion controlled file paths' })
