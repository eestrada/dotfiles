return {
  Lua = {
    runtime = {
      -- Tell the language server which version of Lua is being used
      -- (most likely LuaJIT in the case of Neovim)
      version = 'LuaJIT',
    },
    workspace = {
      checkThirdParty = false,

      -- pull in all of 'runtimepath'. NOTE: this is slower
      library = vim.api.nvim_get_runtime_file('', true),
    },
    telemetry = { enable = false },
    -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
    -- diagnostics = { disable = { 'missing-fields' } },
  },
}
