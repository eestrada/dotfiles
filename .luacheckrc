-- https://luacheck.readthedocs.io/en/stable/config.html
return {
  -- Neovim defines `vim` global implicitly in lua scripts.
  globals = { 'vim' },

  -- Ignore long comment lines.
  max_comment_line_length = false,

  ignore = {
    '212', -- Ignore unused arguments
  },
}
