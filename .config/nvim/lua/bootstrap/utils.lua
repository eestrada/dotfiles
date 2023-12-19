local M = {}

-- Return `true` if file is downloaded, otherwise false
M.download_file = function(install_path, download_url)
  if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    vim.fn.system({ 'curl', '-fLo', install_path, '--create-dirs', download_url })
    return true
  else
    return false
  end
end

M.gettempdir = function()
  return os.getenv("TMPDIR") or os.getenv("TEMP") or os.getenv("TMP") or "/tmp"
end

return M
