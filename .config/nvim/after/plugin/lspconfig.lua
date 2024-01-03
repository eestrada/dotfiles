-- No Neovim LSP stuff should be done when run within VSCode
if vim.g.vscode then
  return
end
-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the mason_managed_servers.
require('mason').setup()
require('mason-lspconfig').setup()

local mason_managed_servers = {
  lua_ls = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using
        -- (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT'
      },
      workspace = {
        checkThirdParty = false,

        -- pull in all of 'runtimepath'. NOTE: this is slower
        library = vim.api.nvim_get_runtime_file("", true)
      },
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

-- Ensure the mason_managed_servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(mason_managed_servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      settings = mason_managed_servers[server_name],
      filetypes = (mason_managed_servers[server_name] or {}).filetypes,
    }
  end,
}

-- Using nvim-lspconfig plugin to quickly configure multiple LSPs with sane defaults. See links below.

-- Servers not managed or auto-installed by mason. These language servers will
-- need to be manually installed, either thru `:Mason` nvim modal, or manually
-- using system tools.
local unmanaged_servers = {
  -- clangd = {},

  -- https://cs.opensource.google/go/x/tools/+/refs/tags/gopls/v0.14.2:gopls/doc/vim.md#neovim
  -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#gopls
  -- Should work so long as `gopls` command is on $PATH
  gopls = {},


  -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#ruby_ls
  ruby_ls = {
    cmd = { 'bundle', 'exec', 'ruby-lsp' },
  },

  -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#solargraph
  -- More documentation on using solargraph with bundler:
  -- https://github.com/castwide/solargraph?tab=readme-ov-file#solargraph-and-bundler
  solargraph = {
    cmd = { 'bundle', 'exec', 'solargraph', 'stdio' },
  },

  -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#rubocop
  -- rubocop = {},

  -- pyright = {},
  -- rust_analyzer = {},
  -- tsserver = {},
  -- html = { filetypes = { 'html', 'twig', 'hbs'} },
}

local lspconfig = require("lspconfig")

for server_name, opts in pairs(unmanaged_servers) do
  local lopts = table.shallowcopy(opts)
  lopts.capabilities = capabilities
  lspconfig[server_name].setup(lopts)
end

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
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
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
    vim.keymap.set('n', 'K', function() vim.lsp.buf.hover() end, { buffer = args.buf, desc = 'Hover Popup' })

    -- telescope builtins
    vim.keymap.set('n', '<C-]>', function() require('telescope.builtin').lsp_definitions() end,
      { buffer = args.buf, desc = 'Goto Definition' })
    vim.keymap.set('n', 'gd', function() require('telescope.builtin').lsp_definitions() end,
      { buffer = args.buf, desc = '[G]oto [D]efinition' })

    -- References
    local telescope_references = function()
      require('telescope.builtin').lsp_references(require('telescope.themes').get_ivy({ include_current_line = true }))
    end
    vim.keymap.set('n', 'gH', telescope_references, { buffer = args.buf, desc = '[G]oto [R]eferences' })
    vim.keymap.set('n', 'gr', telescope_references, { buffer = args.buf, desc = '[G]oto [R]eferences' })
    vim.keymap.set('n', '[I', telescope_references, { buffer = args.buf, desc = 'References' })

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

    -- vim.keymap.set('n', '<C-]>',
    --   function() vim.lsp.buf.definition() end,
    --   { buffer = args.buf, desc = 'Goto Definition' }
    -- )

    -- -- Easier to type than Ctrl-].
    -- -- Also, I'm pretty sure this is defined for ctags, etc. So it is common.
    -- vim.keymap.set('n', 'gd',
    --   function() vim.lsp.buf.definition() end,
    --   { buffer = args.buf, desc = '[g]oto [d]efinition' }
    -- )

    -- vim.keymap.set('n', '<space>D', function() vim.lsp.buf.type_definition() end,
    --   { buffer = args.buf, desc = 'Goto type definition' })

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
    vim.keymap.set('n', '<leader>rn', function() vim.lsp.buf.rename() end, { buffer = args.buf, desc = '[r]e[n]ame' })

    vim.keymap.set({ 'n', 'v' }, '<leader>ca',
      function() vim.lsp.buf.code_action() end,
      { buffer = args.buf, desc = '[c]ode [a]ction' }
    )

    -- This is something different in vscode, but we duplicate it here so that it actually points to something
    vim.keymap.set({ 'n', 'v' }, '<leader>qf',
      function() vim.lsp.buf.code_action() end,
      { buffer = args.buf, desc = 'Quick fix (i.e. Code Action)' }
    )

    vim.keymap.set({ 'n', 'v' }, '<leader>fb',
      function() vim.lsp.buf.format() end,
      { buffer = args.buf, desc = '[f]ormat [b]uffer' }
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
