-- More documentation on using solargraph with bundler:
-- https://github.com/castwide/solargraph?tab=readme-ov-file#solargraph-and-bundler
---@type vim.lsp.Config
return {
  cmd = { 'bundle', 'exec', 'solargraph', 'stdio' },
}
