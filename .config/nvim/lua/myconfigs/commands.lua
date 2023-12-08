-- My custom defined commands
vim.api.nvim_create_user_command(
  'StripTrailingWS',
  [[%s/\s\+$//e]],
  {
    desc = 'Strip all trailing whitespace on lines of current document'
  }
)
