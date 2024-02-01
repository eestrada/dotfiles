
local function download_file(install_path, download_url)
  if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    vim.fn.system({ 'curl', '-fLo', install_path, '--create-dirs', download_url })
    return true
  else
    return false
  end
end

local function gen_config()
  local user_home = os.getenv("HOME")
  local lombok_path = user_home .. "/dev/jdtls/lombok.jar"
  local lombok_dl_url = "https://projectlombok.org/downloads/lombok.jar"
  download_file(lombok_path, lombok_dl_url)

  local config = {
    cmd = {
      -- table.concat({ vim.fn.stdpath("data"), "mason", "bin", "jdtls" }, "/"),
      "jdtls",
      -- By using lombok as the Java agent, all definitions are properly loaded, even for lombok generated method definitions.
      "--jvm-arg=-javaagent:" .. lombok_path,
      "-configuration", user_home .. "/.cache/jdtls/config",
      "-data", user_home .. "/.cache/jdtls/workspace"
    },
  }

  require('jdtls').start_or_attach(config)
end

-- silence errors. Letting them raise causes this not to work, for some reason.
pcall(gen_config)

