-- Using nvim-lspconfig plugin to quickly configure multiple LSPs with sane defaults. See link below.
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#gopls
local lspconfig = require("lspconfig")
-- local autocmd = vim.api.nvim_create_autocmd

-- Based on info in link below:
-- https://cs.opensource.google/go/x/tools/+/refs/tags/gopls/v0.14.2:gopls/doc/vim.md#neovim

-- Default values in link below
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#gopls
-- Should work so long as `gopls` command is on $PATH
lspconfig.gopls.setup({})

-- Mainly used for neovim configs, so using the suggested config from link below
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#lua_ls
-- Should work so long as `lua-language-server` is available on path. See install instruction at link below
-- https://luals.github.io/#neovim-install
lspconfig.lua_ls.setup {
  on_init = function(client)
    local path = client.workspace_folders[1].name
    if not vim.loop.fs_stat(path..'/.luarc.json') and not vim.loop.fs_stat(path..'/.luarc.jsonc') then
      client.config.settings = vim.tbl_deep_extend('force', client.config.settings, {
        Lua = {
          runtime = {
            -- Tell the language server which version of Lua you're using
            -- (most likely LuaJIT in the case of Neovim)
            version = 'LuaJIT'
          },
          -- Make the server aware of Neovim runtime files
          workspace = {
            checkThirdParty = false,
            -- library = {
            --   vim.env.VIMRUNTIME
            --   -- "${3rd}/luv/library"
            --   -- "${3rd}/busted/library",
            -- }
            -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
            library = vim.api.nvim_get_runtime_file("", true)
          }
        }
      })

      client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
    end
    return true
  end
}

-- Other lsp configuration suggestions can be found here:
-- https://github.com/neovim/nvim-lspconfig/blob/master/README.md

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    -- Only redefine uppercase K keymap if current LSP supports hover capability
    if client.server_capabilities.hoverProvider then
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = args.buf, desc = 'Hover Popup' })
    end
    if client.server_capabilities.definitionProvider then
        -- Easier to type than Ctrl-] and works slightly differently too.
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = args.buf, desc = '[G]oto [D]efinition' })
    end
    -- vim.call('autocmd CursorHold  <buffer> lua vim.lsp.buf.document_highlight()')
    -- vim.call('autocmd CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()')
    -- vim.call('autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()')
  end,
})

