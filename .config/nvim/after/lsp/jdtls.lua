local user_home = vim.fn.expand('~')
local cache_dir = vim.fn.stdpath('cache')

-- Assume `jdtls` and friends have been installed by mason already
local mason_registry = require('mason-registry')

local jdtls_install = mason_registry.get_package('jdtls'):get_install_path()
local jdtls_path = jdtls_install .. '/bin/jdtls'
local lombok_path = jdtls_install .. '/lombok.jar'

local java_debug_install = mason_registry.get_package('java-debug-adapter'):get_install_path()
local java_debug_server_jars =
    vim.fn.glob(java_debug_install .. '/extension/server/com.microsoft.java.debug.plugin-*.jar', false, true)

local java_test_install = mason_registry.get_package('java-test'):get_install_path()
local java_test_jars = vim.fn.glob(java_test_install .. '/extension/server/*.jar', false, true)

local bundles = {}
vim.list_extend(bundles, java_debug_server_jars)
vim.list_extend(bundles, java_test_jars)

-- Using a unique workspace_dir avoids clashes that can mess up jdtls
-- See docs here:
-- * permalink: https://codeberg.org/mfussenegger/nvim-jdtls/src/commit/6e9d953f0b82bccdb834cfde0e893f3119c22592/README.md#data-directory-configuration

-- If neovim was started within `~/dev/xy/project-1` this would resolve to `project-1`
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspace_dir = user_home .. '/tmp/jdtls/data/' .. project_name

return {
  cmd = {
    jdtls_path,
    -- By using lombok as the Java agent, all definitions are properly loaded, even for lombok generated method definitions.
    '--jvm-arg=-javaagent:' .. lombok_path,
    '-configuration',
    cache_dir .. '/jdtls/configuration',
    '-data',
    workspace_dir,
  },

  -- Language server `initializationOptions`
  -- You need to extend the `bundles` with paths to jar files
  -- if you want to use additional eclipse.jdt.ls plugins.
  --
  -- See: https://codeberg.org/mfussenegger/nvim-jdtls/src/commit/6e9d953f0b82bccdb834cfde0e893f3119c22592/README.md#java-debug-installation
  --
  -- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
  init_options = {
    bundles = bundles,
  },
}
