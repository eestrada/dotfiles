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
vim.keymap.set('n', '<leader>st', ':Telescope<CR>', { desc = '[s]earch [t]elescope lists' })
vim.keymap.set('n', '<leader>sb', ':Telescope buffers<CR>', { desc = '[s]earch [b]uffers' })
vim.keymap.set('n', '<leader>sc', ':Telescope commands<CR>', { desc = '[s]earch [c]ommands' })
vim.keymap.set('n', '<leader>sg', ':Telescope live_grep<CR>', { desc = '[s]earch by [g]repping file contents' })
vim.keymap.set('n', '<leader>sh', ':Telescope help_tags<CR>', { desc = '[s]earch [h]elp tags' })
vim.keymap.set('n', '<leader>sk', ':Telescope keymaps<CR>', { desc = '[s]earch [k]eymaps' })
vim.keymap.set('n', '<leader>sp', ':Telescope find_files<CR>', { desc = '[s]earch project [p]aths' })
vim.keymap.set('n', '<leader>so', ':Telescope oldfiles<CR>', { desc = '[s]earch [o]ld files opened previously' })
vim.keymap.set('n', '<leader>sv', ':Telescope git_files<CR>', { desc = '[s]earch [v]ersion controlled file paths' })
