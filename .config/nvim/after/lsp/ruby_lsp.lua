-- Documentation on using solargraph with bundler:
-- https://github.com/castwide/solargraph?tab=readme-ov-file#solargraph-and-bundler
return {
  cmd = { 'bundle', 'exec', 'ruby-lsp' },

  -- Don't use eruby for now since it attempts to delegate to another LSP
  -- for HTML, which is VSCode behavior that doesn't exist in Neovim.
  -- filetypes = { 'ruby', 'eruby' },
  filetypes = { 'ruby' },
  init_options = {
    -- formatter = 'standard',
    formatter = 'rubocop',
    -- linters = { 'standard', 'rubocop' },
    linters = { 'rubocop' },
  },
}
