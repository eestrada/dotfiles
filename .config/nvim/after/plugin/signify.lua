if vim.g.vscode then
  return
end

vim.g.signify_sign_delete = '-'

-- I'm still on the fence on whether or not I want to show the count of deleted
-- lines in the gutter.
-- vim.g.signify_sign_show_count = false

-- If `$GIT_EXEC` is defined, then nvim is most likely running as an editor for
-- a git commit message. We should disable signify so that it doesn't
-- unintentionally corrupt the git repo.
if os.getenv("GIT_EXEC") ~= nil then
  vim.cmd(':SignifyDisableAll')
end
