-- No Neovim LSP stuff should be done when run within VSCode
if vim.g.vscode then
  return
end
-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup()
require('mason-lspconfig').setup()

local servers = {
  -- clangd = {},
  gopls = {},
  ruby_ls = {},
  solargraph = {},
  jdtls = {},
  -- pyright = {},
  -- rust_analyzer = {},
  -- tsserver = {},
  -- html = { filetypes = { 'html', 'twig', 'hbs'} },

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
      -- diagnostics = { disable = { 'missing-fields' } },
    },
  },
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end,
}

-- -- Using nvim-lspconfig plugin to quickly configure multiple LSPs with sane defaults. See link below.
-- -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#gopls
-- local lspconfig = require("lspconfig")
-- -- local autocmd = vim.api.nvim_create_autocmd

-- -- Based on info in link below:
-- -- https://cs.opensource.google/go/x/tools/+/refs/tags/gopls/v0.14.2:gopls/doc/vim.md#neovim

-- -- Default values in link below
-- -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#gopls
-- -- Should work so long as `gopls` command is on $PATH
-- lspconfig.gopls.setup({})

-- -- Default values in link below
-- -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#ruby_ls
-- lspconfig.ruby_ls.setup({ cmd = { 'bundle', 'exec', 'ruby-lsp' } })

-- -- Default values in link below
-- -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#solargraph
-- -- More documentation on using with bundler:
-- -- https://github.com/castwide/solargraph?tab=readme-ov-file#solargraph-and-bundler
-- lspconfig.solargraph.setup({ cmd = { 'bundle', 'exec', 'solargraph', 'stdio' } })

-- -- Default values in link below
-- -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#rubocop
-- -- lspconfig.rubocop.setup({})

-- -- Mainly used for neovim configs, so using the suggested config from link below
-- -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#lua_ls
-- -- Should work so long as `lua-language-server` is available on path. See install instruction at link below
-- -- https://luals.github.io/#neovim-install
-- lspconfig.lua_ls.setup {
--   on_init = function(client)
--     local path = client.workspace_folders[1].name
--     if not vim.loop.fs_stat(path .. '/.luarc.json') and not vim.loop.fs_stat(path .. '/.luarc.jsonc') then
--       client.config.settings = vim.tbl_deep_extend('force', client.config.settings, {
--         Lua = {
--           runtime = {
--             -- Tell the language server which version of Lua you're using
--             -- (most likely LuaJIT in the case of Neovim)
--             version = 'LuaJIT'
--           },
--           -- Make the server aware of Neovim runtime files
--           workspace = {
--             checkThirdParty = false,
--             -- library = {
--             --   vim.env.VIMRUNTIME
--             --   -- "${3rd}/luv/library"
--             --   -- "${3rd}/busted/library",
--             -- }
--             -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
--             library = vim.api.nvim_get_runtime_file("", true)
--           }
--         }
--       })

--       client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
--     end
--     return true
--   end
-- }

-- Other lsp configuration suggestions can be found here:
-- https://github.com/neovim/nvim-lspconfig/blob/master/README.md#suggested-configuration

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    vim.keymap.set('n', '<leader>wa', function() vim.lsp.buf.add_workspace_folder() end,
      { buffer = args.buf, desc = '[w]orkspace [a]dd folder' })
    vim.keymap.set('n', '<leader>wr', function() vim.lsp.buf.remove_workspace_folder() end,
      { buffer = args.buf, desc = '[w]orkspace [r]emove folder' })
    vim.keymap.set('n', '<leader>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end,
      { buffer = args.buf, desc = '[w]orkspace [l]ist folders' })

    -- Start of keymaps that shadow existing keymaps
    -- Only redefine uppercase K keymap if current LSP supports hover capability
    if client.server_capabilities.hoverProvider then
      vim.keymap.set('n', 'K', function() vim.lsp.buf.hover() end, { buffer = args.buf, desc = 'Hover Popup' })
    end

    vim.keymap.set('n', '<C-]>', function() require('telescope.builtin').lsp_definitions() end,
      { buffer = args.buf, desc = 'Goto Definition' })
    vim.keymap.set('n', 'gd', function() require('telescope.builtin').lsp_definitions() end,
      { buffer = args.buf, desc = '[G]oto [D]efinition' })
    vim.keymap.set('n', 'gH', function() require('telescope.builtin').lsp_references() end,
      { buffer = args.buf, desc = '[G]oto [R]eferences' })
    vim.keymap.set('n', 'gr', function() require('telescope.builtin').lsp_references() end,
      { buffer = args.buf, desc = '[G]oto [R]eferences' })
    vim.keymap.set('n', '[I', function() require('telescope.builtin').lsp_references() end,
      { buffer = args.buf, desc = 'References' })
    vim.keymap.set('n', 'gi', function() require('telescope.builtin').lsp_implementations() end,
      { buffer = args.buf, desc = '[G]oto [I]mplementation' })
    vim.keymap.set('n', '<leader>D', function() require('telescope.builtin').lsp_type_definitions() end,
      { buffer = args.buf, desc = 'Type [D]efinition' })
    vim.keymap.set('n', '<leader>ds', function() require('telescope.builtin').lsp_document_symbols() end,
      { buffer = args.buf, desc = '[D]ocument [S]ymbols' })
    vim.keymap.set('n', '<leader>ws', function() require('telescope.builtin').lsp_dynamic_workspace_symbols() end,
      { buffer = args.buf, desc = '[W]orkspace [S]ymbols' })
    vim.keymap.set('n', 'gD', function() vim.lsp.buf.declaration() end, { buffer = args.buf, desc = 'Goto declaration' })

    -- Same key bindings as above without telescope support
    -- vim.keymap.set('n', 'gi', function() vim.lsp.buf.implementation() end,
    --   { buffer = args.buf, desc = 'Goto implementation' })

    -- if client.server_capabilities.definitionProvider then
    --   vim.keymap.set('n', '<C-]>',
    --     function() vim.lsp.buf.definition() end,
    --     { buffer = args.buf, desc = 'Goto Definition' }
    --   )

    --   -- Easier to type than Ctrl-].
    --   -- Also, I'm pretty sure this is defined for ctags, etc. So it is common.
    --   vim.keymap.set('n', 'gd',
    --     function() vim.lsp.buf.definition() end,
    --     { buffer = args.buf, desc = '[g]oto [d]efinition' }
    --   )

    --   vim.keymap.set('n', '<space>D', function() vim.lsp.buf.type_definition() end,
    --     { buffer = args.buf, desc = 'Goto type definition' })
    -- end

    -- if client.server_capabilities.referencesProvider then
    --   vim.keymap.set('n', 'gH', function() vim.lsp.buf.references() end,
    --     { buffer = args.buf, desc = 'Goto references' })
    --   vim.keymap.set('n', 'gr', function() vim.lsp.buf.references() end,
    --     { buffer = args.buf, desc = 'Goto references' })
    --   vim.keymap.set('n', '[I', function() vim.lsp.buf.references() end, { buffer = args.buf, desc = 'References' })
    -- end

    vim.keymap.set('n', '<C-k>',
      function() vim.lsp.buf.signature_help() end,
      { buffer = args.buf, desc = 'Signature help' }
    )

    -- custom keymaps using <leader> key
    if client.server_capabilities.renameProvider then
      vim.keymap.set('n', '<leader>rn', function() vim.lsp.buf.rename() end, { buffer = args.buf, desc = '[r]e[n]ame' })
    end

    -- custom keymaps using <leader> key
    vim.keymap.set({ 'n', 'v' }, '<leader>ca',
      function() vim.lsp.buf.code_action() end,
      { buffer = args.buf, desc = '[c]ode [a]ction' }
    )

    -- This is something different in vscode, but we duplicate it here so that it actually points to something
    vim.keymap.set({ 'n', 'v' }, '<leader>qf',
      function() vim.lsp.buf.code_action() end,
      { buffer = args.buf, desc = 'Quick fix (i.e. Code Action)' }
    )

    vim.api.nvim_buf_create_user_command(
      args.buf,
      'FmtBuffer',
      function() vim.lsp.buf.format({ bufnr = args.buf }) end,
      {
        desc = 'Format entire buffer'
      }
    )
    -- foldingRangeProvider
    if client.server_capabilities.documentHighlightProvider then
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
    end
  end,
})
