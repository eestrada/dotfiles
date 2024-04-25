-- vim: set foldmethod=marker:
-- [[ Utility functions ]] {{{1


-- Dump a table to a readable string. See original implementation here:
-- https://stackoverflow.com/a/27028488/1733321
function table.dump(orig)
  if type(orig) == 'table' then
    local s = '{ '
    for k, v in pairs(orig) do
      if type(k) ~= 'number' then k = '"' .. k .. '"' end
      s = s .. '[' .. k .. '] = ' .. table.dump(v) .. ','
    end
    return s .. '} '
  else
    return tostring(orig)
  end
end

-- Shallow copy table contents. nested cloning does not work.
-- Implementation from here: http://lua-users.org/wiki/CopyTable
function table.shallowcopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
    copy = {}
    for orig_key, orig_value in pairs(orig) do
      copy[orig_key] = orig_value
    end
  else -- number, string, boolean, etc
    copy = orig
  end
  return copy
end

local function format_setqflist_what(item)
  return string.format('%s|%s col %s| %s', item.filename, item.lnum, item.col, string.gsub(item.text, '^%s+', ''))
end

local function download_file(install_path, download_url)
  if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    vim.fn.system({ 'curl', '-fLo', install_path, '--create-dirs', download_url })
    return true
  else
    return false
  end
end

local function ensure_vim_plug()
  local fn = vim.fn

  local install_path = fn.stdpath('data') .. '/site/autoload/plug.vim'
  local vim_plug_url = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  local bootstrapped = download_file(install_path, vim_plug_url)
  if bootstrapped then
    -- Source it explicitly this first time. Will be autoloaded by neovim on
    -- future startups.
    vim.cmd('source ' .. install_path)
    return true
  else
    return false
  end
end

local function load_vim_plug()
  local no_error, bootstrapped = pcall(ensure_vim_plug)
  if no_error then
    -- Module for the [vim-plug plugin manager](https://github.com/junegunn/vim-plug)
    local plug = {}

    -- Indicate whether plug was bootstrapped on this run. i.e. was it
    -- downloaded and sourced on this run of the config.
    plug.Bootstrapped = bootstrapped

    -- Define an individual plugin
    plug.Plug = vim.fn['plug#']

    -- Begin plugin definitions
    plug.Begin = vim.fn['plug#begin']

    -- End plugin definitions
    plug.End = vim.fn['plug#end']

    -- Interactive command(s) that *can* be useful in scripting

    -- Install defined plugins
    function plug.Install() vim.cmd(':PlugInstall') end

    return plug
  else
    return nil
  end
end

-- [[ Utility Variables ]] {{{1
local user_home = os.getenv("HOME")

-- [[ Define functions for plugin setup ]] {{{1

-- [[ Configure VSCode ]] {{{2
local function vscode_setup()
  local vscode = require('vscode-neovim')

  -- Set vscode.notify as default notify function. See docs here:
  -- https://github.com/vscode-neovim/vscode-neovim?tab=readme-ov-file#vscodenotifymsg
  vim.notify = vscode.notify

  -- It doesn't seem like the commentary code linked below is necessary anymore
  -- https://github.com/vscode-neovim/vscode-neovim/wiki/Plugins#vim-commentary

  -- Use common keybindings
  vim.keymap.set('n', '[I', function() vscode.call('editor.action.referenceSearch.trigger') end,
    { desc = 'References' })

  vim.keymap.set('n', '<C-]>', function() vscode.call('editor.action.revealDefinition') end,
    { desc = 'Goto definition' })

  vim.keymap.set('n', ']d', function() vscode.call('editor.action.marker.next') end,
    { desc = 'Goto next diagnostic message' })

  vim.keymap.set('n', '[d', function() vscode.call('editor.action.marker.prev') end,
    { desc = 'Goto previous diagnostic message' })

  vim.keymap.set('n', '<leader>dl', function() vscode.call('workbench.actions.view.problems') end,
    { desc = 'Open diagnostic location list' })

  -- Act like vim signify and jump between diff changes in editor
  vim.keymap.set('n', ']c', function() vscode.call('workbench.action.editor.nextChange') end,
    { desc = 'Goto next diff change' })

  vim.keymap.set('n', '[c', function() vscode.call('workbench.action.editor.previousChange') end,
    { desc = 'Goto previous diff change' })

  -- Keymaps used by lsp buffers
  vim.keymap.set('n', 'gi', function() vscode.call('editor.action.goToImplementation') end,
    { desc = 'Goto implementation' })

  vim.keymap.set('n', 'gD', function() vscode.call('editor.action.revealDeclaration') end,
    { desc = 'Goto declaration' })

  vim.keymap.set('n', '<space>D', function() vscode.call('editor.action.goToTypeDefinition') end,
    { desc = 'Goto type definition' })

  vim.keymap.set('n', '<leader>rn', function() vscode.call('editor.action.rename') end,
    { desc = '[r]e[n]ame' })

  vim.keymap.set('n', '<space>ca', function() vscode.call('editor.action.sourceAction') end,
    { desc = 'Code action' })

  vim.keymap.set('n', '<space>qf', function() vscode.call('editor.action.quickFix') end,
    { desc = 'Quick fix' })

  -- Add keybindings for telescope tools used often
  vim.keymap.set('n', '<space>sc', function() vscode.call('workbench.action.showCommands') end,
    { desc = '[s]earch [c]ommands' })

  vim.keymap.set('n', '<space>sg', function() vscode.call('workbench.action.findInFiles') end,
    { desc = '[s]earch file contents with [g]rep' })

  vim.keymap.set('n', '<space>sp', function() vscode.call('workbench.action.quickOpenNavigateNextInFilePicker') end,
    { desc = '[s]earch project [p]aths' })
end

-- [[ Configure lsp ]] {{{2
local function lsp_config_setup()
  -- Setup neovim lua configuration
  -- IMPORTANT: make sure to setup neodev BEFORE lspconfig. See here:
  -- https://github.com/folke/neodev.nvim?tab=readme-ov-file#-setup
  require('neodev').setup()

  local mason_ensure_installed = {
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

  -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

  -- mason-lspconfig requires that mason be setup before setting up the
  -- mason_ensure_installed LSP servers.
  require('mason').setup()

  -- Ensure the mason_ensure_installed LSP servers above are installed.
  require('mason-lspconfig').setup {
    ensure_installed = vim.tbl_keys(mason_ensure_installed),
  }

  -- Using nvim-lspconfig plugin to quickly configure multiple LSPs with sane defaults. See links below.

  -- Servers not managed or auto-installed by mason. These language servers will
  -- need to be manually installed, either thru `:Mason` nvim modal, or manually
  -- using system tools.
  local unmanaged_servers = {
    -- https://cs.opensource.google/go/x/tools/+/refs/tags/gopls/v0.14.2:gopls/doc/vim.md#neovim
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#gopls
    -- Should work so long as `gopls` command is on $PATH
    gopls = {},


    -- -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#ruby_ls
    -- ruby_ls = {
    --   cmd = { 'bundle', 'exec', 'ruby-lsp' },
    -- },

    -- for ruby
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#solargraph
    -- More documentation on using solargraph with bundler:
    -- https://github.com/castwide/solargraph?tab=readme-ov-file#solargraph-and-bundler
    solargraph = {
      cmd = { 'bundle', 'exec', 'solargraph', 'stdio' },
    },

    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#rubocop
    -- rubocop = {},

    -- for python
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#pyright
    pyright = {},

    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#html
    html = {},

    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#jsonls
    jsonls = {},

    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#cssls
    cssls = {},

    -- for typescript/javascript
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#tsserver
    tsserver = {},

    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#yamlls
    yamlls = {},

    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#lemminx
    lemminx = {
      filetypes = { "xml", "xsd", "xsl", "xslt", "svg", "ant" },
    },

    -- for markdown
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#remark_ls
    remark_ls = {},

    -- for markdown
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#marksman
    marksman = {},

    -- for toml
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#taplo
    taplo = {},

    -- for vimscript
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#vimls
    vimls = {},

    -- for zig
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#zls
    zls = {},
  }

  for key, value in pairs(mason_ensure_installed) do
    unmanaged_servers[key] = value
  end

  local lspconfig = require("lspconfig")

  for server_name, opts in pairs(unmanaged_servers) do
    local lopts = table.shallowcopy(opts)
    lopts.capabilities = capabilities
    local single_config = lspconfig[server_name]
    if single_config then
      single_config.setup(lopts)
    end
  end

  -- Other lsp configuration suggestions can be found here:
  -- https://github.com/neovim/nvim-lspconfig/blob/master/README.md#suggested-configuration

  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'java',
    group = vim.api.nvim_create_augroup('NvimJdtlsConfig', { clear = true }),
    callback = function()
      vim.api.nvim_buf_create_user_command(0, 'JdtTestClass',
        function()
          require('jdtls').test_class()
        end, { desc = 'Test current class using Java JDT with DAP debugging capabilities enabled.' }
      )

      vim.api.nvim_buf_create_user_command(0, 'JdtTestNearestMethod',
        function()
          require('jdtls').test_nearest_method()
        end, { desc = 'Test nearest method using Java JDT with DAP debugging capabilities enabled.' }
      )

      local cache_dir = vim.fn.stdpath("cache")

      -- Assume `jdtls` and friends have been installed by mason already
      local mason_registry = require('mason-registry')

      local jdtls_install = mason_registry
          .get_package('jdtls')
          :get_install_path()
      local jdtls_path = jdtls_install .. '/bin/jdtls'
      local lombok_path = jdtls_install .. '/lombok.jar'

      local java_debug_install = mason_registry
          .get_package('java-debug-adapter')
          :get_install_path()
      local java_debug_server_jars = vim.fn.glob(
        java_debug_install .. '/extension/server/com.microsoft.java.debug.plugin-*.jar',
        false,
        true
      )

      local java_test_install = mason_registry
          .get_package('java-test')
          :get_install_path()
      local java_test_jars = vim.fn.glob(
        java_test_install .. '/extension/server/*.jar',
        false,
        true
      )

      local bundles = {}
      vim.list_extend(bundles, java_debug_server_jars)
      vim.list_extend(bundles, java_test_jars)

      require('jdtls').start_or_attach({
        cmd = {
          jdtls_path,
          -- By using lombok as the Java agent, all definitions are properly loaded, even for lombok generated method definitions.
          "--jvm-arg=-javaagent:" .. lombok_path,
          "-configuration", cache_dir .. "/jdtls/configuration",
          "-data", cache_dir .. "/jdtls/data"
        },

        -- Language server `initializationOptions`
        -- You need to extend the `bundles` with paths to jar files
        -- if you want to use additional eclipse.jdt.ls plugins.
        --
        -- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
        --
        -- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
        init_options = {
          bundles = bundles,
        },
      })
    end,
  })

  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', { clear = false }),
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)

      local function references_on_list(options)
        vim.fn.setqflist({}, ' ', options)
        vim.api.nvim_command('botright copen')

        -- Most references I want to see are in the same window that the cursor
        -- is already in, so return to that window from the Quickfix window.
        vim.api.nvim_command('wincmd p')
      end

      local function location_on_list(options)
        vim.fn.setqflist({}, ' ', options)

        if #options.items == 0 then
          vim.notify("No " .. options.title .. " to jump to.", vim.log.levels.WARN)
        elseif #options.items == 1 then
          vim.api.nvim_command('cfirst')
        else
          vim.api.nvim_command('botright copen')
          vim.api.nvim_command('wincmd p')
          require('periscope.builtin').quickfix()
        end
      end

      local references_lsp_options = { on_list = references_on_list }
      local location_lsp_options = { on_list = location_on_list }

      vim.keymap.set('n', '<leader>wa', function() vim.lsp.buf.add_workspace_folder() end,
        { buffer = args.buf, desc = '[w]orkspace [a]dd folder' })
      vim.keymap.set('n', '<leader>wr', function() vim.lsp.buf.remove_workspace_folder() end,
        { buffer = args.buf, desc = '[w]orkspace [r]emove folder' })
      vim.keymap.set('n', '<leader>wl', function() vim.print(vim.lsp.buf.list_workspace_folders()) end,
        { buffer = args.buf, desc = '[w]orkspace [l]ist folders' })

      -- Start of keymaps that shadow existing keymaps
      -- Only redefine uppercase K keymap if current LSP supports hover capability
      vim.keymap.set('n', 'K', function() vim.lsp.buf.hover() end, { buffer = args.buf, desc = 'Hover Popup' })

      -- telescope builtins
      local function definition_func()
        vim.lsp.buf.definition(location_lsp_options)
      end
      -- We bind `gd` to `<C-]>` in `init.vim`
      vim.keymap.set('n', '<C-]>', definition_func, { buffer = args.buf, desc = 'Goto Definition' })

      -- References
      -- Use the following link for reference on how to override the default
      -- references behavior.
      -- https://github.com/pbogut/dotfiles/blob/7ba96f5871868c1ce02f4b3832c1659637fb0c2c/config/nvim/lua/plugins/nvim_lsp.lua#L88C1-L101C4
      local function references_func()
        vim.lsp.buf.references(nil, references_lsp_options)
      end
      -- We bind `gr` to `[I` in `init.vim`
      vim.keymap.set('n', '[I', references_func, { buffer = args.buf, desc = 'References' })

      local function implementation_func()
        vim.lsp.buf.implementation(location_lsp_options)
      end
      vim.keymap.set('n', 'gi', implementation_func, { buffer = args.buf, desc = '[g]oto [i]mplementation' })

      vim.keymap.set('n', 'gD', function() vim.lsp.buf.declaration(location_lsp_options) end,
        { buffer = args.buf, desc = '[g]oto [D]eclaration' })

      vim.keymap.set('n', '<C-k>',
        function() vim.lsp.buf.signature_help() end,
        { buffer = args.buf, desc = 'Signature help' }
      )

      local function type_definition_func()
        vim.lsp.buf.type_definition(location_lsp_options)
      end
      vim.keymap.set('n', 'gt', type_definition_func, { buffer = args.buf, desc = '[g]oto [t]ype definition' })

      vim.keymap.set('n', '<leader>sd', function() require('telescope.builtin').lsp_document_symbols() end,
        { buffer = args.buf, desc = '[s]earch [d]ocument symbols' })

      vim.keymap.set('n', '<leader>sw', function() require('telescope.builtin').lsp_dynamic_workspace_symbols() end,
        { buffer = args.buf, desc = '[s]earch [w]orkspace symbols' })

      -- custom keymaps using <leader> key
      vim.keymap.set('n', '<leader>rn', function() vim.lsp.buf.rename() end, { buffer = args.buf, desc = '[r]e[n]ame' })

      vim.keymap.set({ 'n', 'v' }, '<leader>ca',
        function() vim.lsp.buf.code_action() end,
        { buffer = args.buf, desc = '[c]ode [a]ction' }
      )

      -- This is something different in vscode, but we duplicate it here so that it actually points to something
      vim.keymap.set({ 'n', 'v' }, '<leader>qf',
        function() vim.lsp.buf.code_action() end,
        { buffer = args.buf, desc = '[q]uick [f]ix (i.e. Code Action)' }
      )

      vim.keymap.set({ 'n', 'v' }, '<leader>fb',
        function() vim.lsp.buf.format() end,
        { buffer = args.buf, desc = '[f]ormat [b]uffer' }
      )

      -- Get capabilities of current LSP server
      vim.api.nvim_create_user_command('LspCapabilities',
        function()
          vim.print(vim.lsp.get_active_clients({ bufnr = vim.api.nvim_get_current_buf() })[1].server_capabilities)
        end, { desc = 'Print capabilities of current LSP server implementation.' }
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
end

-- [[ Configure go ]] {{{2
local function go_setup()
  local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
  vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.go",
    callback = function()
      require('go.format').goimport()
    end,
    group = format_sync_grp,
  })

  require("go").setup()
end

-- [[ Configure nvim-cmp ]] {{{2
-- See `:help cmp`
local function cmp_setup()
  local cmp = require('cmp')
  local luasnip = require('luasnip')
  require('luasnip.loaders.from_vscode').lazy_load()
  require('luasnip.loaders.from_vscode').lazy_load()
  luasnip.config.setup {}

  cmp.setup {
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    completion = {
      completeopt = 'menu,menuone,noinsert',
    },
    mapping = cmp.mapping.preset.insert {
      ['<C-n>'] = cmp.mapping.select_next_item(),
      ['<C-p>'] = cmp.mapping.select_prev_item(),
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete {},
      ['<CR>'] = cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Replace,
        select = true,
      },
      ['<Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_locally_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { 'i', 's' }),
      ['<S-Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.locally_jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { 'i', 's' }),
    },
    sources = {
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
      { name = 'path' },
    },
  }
end

-- [[ Configure fidget ]] {{{2
local function fidget_setup()
  require("fidget").setup({
    -- Options related to LSP progress subsystem
    progress = {
      -- Options related to how LSP progress messages are displayed as notifications
      display = {
        skip_history = false, -- Whether progress notifications should be omitted from history
      },
    },
  })

  -- Use fidget for notifications instead of the builtin notify function.
  vim.notify = require('fidget.notification').notify
end

-- [[ Configure periscope ]] {{{2
local function periscope_setup(opts)
  require("periscope").setup(opts)

  -- Fuzzy keymaps
  vim.keymap.set('n', '<leader>ss', function() require('periscope.builtin').builtin() end,
    { desc = '[s]earch periscope [s]electors' })
  vim.keymap.set('n', '<leader>sb', function() require('periscope.builtin').buffers() end,
    { desc = '[s]earch [b]uffers' })
  vim.keymap.set('n', '<leader>sc', function() require('periscope.builtin').commands() end,
    { desc = '[s]earch [c]ommands' })
  vim.keymap.set('n', '<leader>sg', function() require('periscope.builtin').live_grep() end,
    { desc = '[s]earch file contents with [g]rep' })
  vim.keymap.set('n', '<leader>sh', function() require('periscope.builtin').help_tags() end,
    { desc = '[s]earch [h]elp tags' })
  vim.keymap.set('n', '<leader>sk', function() require('periscope.builtin').keymaps() end,
    { desc = '[s]earch [k]eymaps' })
  vim.keymap.set('n', '<leader>sp', function() require('periscope.builtin').find_files() end,
    { desc = '[s]earch project [p]aths' })
  vim.keymap.set('n', '<leader>so', function() require('periscope.builtin').oldfiles() end,
    { desc = '[s]earch [o]ld files opened previously' })
  vim.keymap.set('n', '<leader>sv', function() require('periscope.builtin').git_files() end,
    { desc = '[s]earch [v]ersion controlled file paths' })
  vim.keymap.set('n', '<leader>sj', function() require('periscope.builtin').jumplist() end,
    { desc = '[s]earch periscope [j]umplist' })
  vim.keymap.set('n', 'z=', function() require('periscope.builtin').spell_suggest() end, { desc = 'Spell suggestions' })
end

-- [[ Configure DAP ]] {{{2
local function dap_setup()
  vim.keymap.set('n', '<F1>', function() require('dap').step_out() end, { desc = 'DAP step out' })
  vim.keymap.set('n', '<F2>', function() require('dap').step_into() end, { desc = 'DAP step into' })
  vim.keymap.set('n', '<F3>', function() require('dap').step_over() end, { desc = 'DAP step over' })
  vim.keymap.set('n', '<F4>', function() require('dap').continue() end, { desc = 'DAP continue' })
  vim.keymap.set('n', '<leader>b', function() require('dap').toggle_breakpoint() end, { desc = 'DAP toggle breakpoint' })
  vim.keymap.set('n', '<leader>B', function() require('dap').set_breakpoint() end, { desc = 'DAP set breakpoint' })
  vim.keymap.set('n', '<leader>dm',
    function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end,
    { desc = 'DAP Log point message' })
  vim.keymap.set('n', '<leader>dr', function() require('dap').repl.open() end, { desc = 'DAP REPL open' })
  vim.keymap.set('n', '<leader>dl', function() require('dap').run_last() end, { desc = 'DAP run last' })

  vim.keymap.set({ 'n', 'v' }, '<leader>dh',
    function()
      require('dap.ui.widgets').hover()
    end,
    { desc = 'DAP UI hover' }
  )
  vim.keymap.set({ 'n', 'v' }, '<leader>dp',
    function()
      require('dap.ui.widgets').preview()
    end,
    { desc = 'DAP UI preview' }
  )
  vim.keymap.set('n', '<leader>df',
    function()
      local widgets = require('dap.ui.widgets')
      widgets.centered_float(widgets.frames)
    end,
    { desc = 'DAP UI centered float frames' }
  )
  vim.keymap.set('n', '<leader>ds',
    function()
      local widgets = require('dap.ui.widgets')
      widgets.centered_float(widgets.scopes)
    end,
    { desc = 'DAP UI centered float scopes' }
  )

  local dap = require("dap")
  local dapui = require("dapui")
  dapui.setup()

  dap.listeners.before.attach.dapui_config = function()
    dapui.open()
  end
  dap.listeners.before.launch.dapui_config = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated.dapui_config = function()
    dapui.close()
  end
  dap.listeners.before.event_exited.dapui_config = function()
    dapui.close()
  end

  local function codelldb_setup(filetype)
    if not dap.adapters.codelldb then
      -- Configuration originally from:
      -- https://github.com/mfussenegger/nvim-dap/wiki/C-C---Rust-%28via--codelldb%29
      local mason_registry = require('mason-registry')
      local codelldb_install = mason_registry
          .get_package('codelldb')
          :get_install_path()
      local codelldb_path = codelldb_install .. '/codelldb'

      -- codelldb can be used for most natively compiled code with debugging symbols present.
      dap.adapters.codelldb = {
        type = 'server',
        port = "${port}",
        executable = {
          command = codelldb_path,
          args = { "--port", "${port}" },

          -- On windows you may have to uncomment this:
          -- detached = false,
        }
      }
    end

    if not dap.configurations[filetype] then
      dap.configurations[filetype] = {
        {
          name = "Launch file",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input({
              prompt = 'Path to executable: ',
              default = vim.fn.getcwd() .. '/',
              completion = 'file',
            })
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
        },
      }
    end
  end

  local codelldb_filetypes = {
    'c',
    'cpp',
    'rust',
    'zig',
  }

  -- Lazily setup codelldb for dap when we encounter supported filetypes.
  for _, ft in ipairs(codelldb_filetypes) do
    vim.api.nvim_create_autocmd('FileType', {
      pattern = ft,
      group = vim.api.nvim_create_augroup('DapCodelldbConfig_' .. ft, { clear = true }),
      callback = function()
        codelldb_setup(ft)

        -- zig executables are in well known locations, just list those instead
        -- of asking for a full path from the user, like is done for c, cpp,
        -- and rust.
        if ft == 'zig' then
          dap.configurations.zig = {
            {
              name = "Launch file",
              type = "codelldb",
              request = "launch",
              program = function()
                local root = vim.fn.getcwd()

                local execs = vim.fn.glob(
                  root .. '/zig-out/bin/*',
                  false,
                  true
                )
                local test_execs = vim.fn.glob(
                  root .. '/zig-cache/o/*/test',
                  false,
                  true
                )

                local all_paths = {}

                vim.list_extend(all_paths, execs)
                vim.list_extend(all_paths, test_execs)

                local for_display = { "Select executable:" }

                for index, value in ipairs(all_paths) do
                  table.insert(for_display, string.format("%d. %s", index, value))
                end

                local choice = vim.fn.inputlist(for_display)
                local final_choice = all_paths[choice]

                vim.print(choice)
                vim.print(final_choice)

                return final_choice
              end
              ,
              cwd = '${workspaceFolder}',
              stopOnEntry = false,
            },
          }
        end
      end,
    })
  end
end

-- [[ Configure Dressing ]] {{{2
local function dressing_setup()
  -- https://github.com/stevearc/dressing.nvim?tab=readme-ov-file#configuration
  require("dressing").setup({
    select = {
      -- Options for telescope selector
      -- These are passed into the telescope picker directly. Can be used like:
      -- telescope = require('telescope.themes').get_ivy({...})
      telescope = require('telescope.themes').get_ivy({ include_current_line = true }),
    },
  })
end

-- [[ Configure telescope ]] {{{2
local function telescope_setup()
  require("telescope").setup({})
end

-- [[ Configure Treesitter ]] {{{2
local function treesitter_setup()
  require('nvim-treesitter.configs').setup {
    modules = {},        -- Added to silence linter
    ignore_install = {}, -- Added to silence linter

    -- A list of parser names, or "all" (the five listed parsers should always be installed)
    ensure_installed = { "lua", "vim", "vimdoc", "query" },

    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,

    -- Automatically install missing parsers when entering buffer
    -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
    auto_install = false,

    ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
    -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

    highlight = {
      enable = true,

      -- use a function to disable slow treesitter highlight for large files
      disable = function(lang, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
          return true
        end
      end,

      -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
      -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
      -- Using this option may slow down your editor, and you may see some duplicate highlights.
      -- Instead of true it can also be a list of languages
      additional_vim_regex_highlighting = false,
    },
  }

  local parser_config = require('nvim-treesitter.parsers').get_parser_configs()

  parser_config.gotmpl = {
    install_info = {
      url = "https://github.com/ngalaiko/tree-sitter-go-template",
      files = { "src/parser.c" }
    },
    filetype = "gotmpl",
    used_by = { "gohtmltmpl", "gotexttmpl", "gotmpl" }
  }
end

-- [[ Configure inside VSCode ]] {{{1
if vim.g.vscode then
  local vscode_setup_succeed, vscode_err = pcall(vscode_setup)
  if not vscode_setup_succeed then
    vim.notify(
      string.format('VSCode setup failed. Check nvim config based on errors: %s', vscode_err),
      vim.log.levels.ERROR
    )
  end
else
  -- [[ Configure standalone Neovim ]] {{{1
  -- [[ Keymaps for nvim only ]] {{{2
  -- See `:help vim.keymap.set()`
  vim.keymap.set('n', '<leader>nf', function() vim.diagnostic.open_float() end,
    { desc = 'Open diag[n]ostic [f]loat' })
  vim.keymap.set('n', '[d', function() vim.diagnostic.goto_prev() end,
    { desc = 'Goto previous diagnostic message' })
  vim.keymap.set('n', ']d', function() vim.diagnostic.goto_next() end,
    { desc = 'Goto next diagnostic message' })
  vim.keymap.set('n', '<leader>nl', function() vim.diagnostic.setloclist() end,
    { desc = 'Open diag[n]ostics in [l]ocation list' })
  vim.keymap.set('n', '<leader>nq', function() vim.diagnostic.setqflist() end,
    { desc = 'Open diag[n]ostics in [q]uickfix list' })

  -- Ideas originated from links below:
  -- * https://superuser.com/questions/875095/adding-parenthesis-around-highlighted-text-in-vim#875160
  -- * https://superuser.com/questions/875095/adding-parenthesis-around-highlighted-text-in-vim#comment2405624_875160
  vim.keymap.set('v', '<leader>wv',
    function()
      vim.ui.input({ prompt = 'Wrap text: ' }, function(input)
        if input then
          vim.cmd('normal! d')
          vim.cmd("normal! i" .. input)
          vim.cmd "stopinsert"
          vim.cmd("normal! P")
        end
      end)
    end,
    { desc = '[w]rap [v]isible selection in input text' })

  -- [[ User commands for nvim only ]] {{{2
  -- Originally ideas found here: https://gist.github.com/atripes/15372281209daf5678cded1d410e6c16?permalink_comment_id=3634542#gistcomment-3634542
  -- vim.api.nvim_create_user_command('UrlEncode',
  --   function(opts)
  --     -- vim.fn.getpos()
  --     local start_pos = vim.fn.getpos("'<")
  --     local end_pos = vim.fn.getpos("'>")
  --     local region = vim.region(0, start_pos, end_pos, "v", true)
  --     print(region)
  --   end, { desc = 'Url encode selection.' }
  -- )

  -- [[ Configurations in functions ]] {{{2
  local init_funcs = {
    fidget = fidget_setup,
    dap = dap_setup,
    golang = go_setup,
    ['lsp config'] = lsp_config_setup,
    ['cmp and luasnip'] = cmp_setup,
    telescope = telescope_setup,
    treesitter = treesitter_setup,
    periscope = periscope_setup,
    dressing = dressing_setup,
  }

  for setup_name, setup_func in pairs(init_funcs) do
    local setup_succeed, setup_err = pcall(setup_func)
    if not setup_succeed then
      vim.notify(
        string.format('%s setup failed. Check nvim config based on errors: %s', setup_name, setup_err),
        vim.log.levels.ERROR
      )
    end
  end
end
