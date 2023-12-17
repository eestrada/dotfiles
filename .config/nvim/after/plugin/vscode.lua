if not vim.g.vscode then
  return
end

-- Behave like vim-commentary plugin when in vscode
vim.call('xmap gc <Plug>VSCodeCommentary')
vim.call('nmap gc <Plug>VSCodeCommentary')
vim.call('omap gc <Plug>VSCodeCommentary')
vim.call('nmap gcc <Plug>VSCodeCommentaryLine')
