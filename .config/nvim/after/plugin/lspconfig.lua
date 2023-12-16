-- No Neovim LSP stuff should be done when run within VSCode
if vim.g.vscode then
  return
end

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
    if not vim.loop.fs_stat(path .. '/.luarc.json') and not vim.loop.fs_stat(path .. '/.luarc.jsonc') then
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

    -- Start of keymaps that shadow existing keymaps
    -- Only redefine uppercase K keymap if current LSP supports hover capability
    if client.server_capabilities.hoverProvider then
      vim.keymap.set('n', 'K', function() vim.lsp.buf.hover() end, { buffer = args.buf, desc = 'Hover Popup' })
    end
    if client.server_capabilities.definitionProvider then
      vim.keymap.set('n', '<C-]>',
        function() vim.lsp.buf.definition() end,
        { buffer = args.buf, desc = 'Goto Definition' }
      )
      -- Easier to type than Ctrl-].
      vim.keymap.set('n', 'gd',
        function() vim.lsp.buf.definition() end,
        { buffer = args.buf, desc = '[G]oto [D]efinition' }
      )
    end
    if client.server_capabilities.referencesProvider then
      vim.keymap.set('n', '[I', function() vim.lsp.buf.references() end, { buffer = args.buf, desc = 'References' })
    end
    vim.keymap.set('n', '<C-k>',
      function() vim.lsp.buf.signature_help() end,
      { buffer = args.buf, desc = 'Signature help' }
    )
    vim.keymap.set('n', '[d', function() vim.diagnostic.goto_next() end, { buffer = args.buf })
    vim.keymap.set('n', ']d', function() vim.diagnostic.goto_prev() end, { buffer = args.buf })

    -- custom keymaps using <leader> key
    if client.server_capabilities.renameProvider then
      vim.keymap.set('n', '<leader>rn', function() vim.lsp.buf.rename() end, { buffer = args.buf, desc = '[R]e[N]ame' })
    end
    vim.keymap.set('n', '<leader>ca',
      function() vim.lsp.buf.code_action() end,
      { buffer = args.buf, desc = '[C]ode [A]ction' }
    )

    vim.api.nvim_buf_create_user_command(
      args.buf,
      'FmtBuffer',
      function() vim.lsp.buf.format({ bufnr = args.buf }) end,
      {
        desc = 'Format entire buffer'
      }
    )

    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
      pattern = '<buffer>',
      callback = function()
        vim.lsp.buf.document_highlight()
      end
    })
    vim.api.nvim_create_autocmd('CursorMoved', {
      pattern = '<buffer>',
      callback = function()
        vim.lsp.buf.clear_references()
      end
    })
  end,
})
