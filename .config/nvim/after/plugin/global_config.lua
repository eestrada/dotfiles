-- vim: set foldmethod=marker foldlevel=0:
-- [[ Utility functions ]] {{{1

-- Dump a table to a readable string. See original implementation here:
-- https://stackoverflow.com/a/27028488/1733321
local function table_dump(orig)
  if type(orig) == 'table' then
    local s = '{ '
    for k, v in pairs(orig) do
      if type(k) ~= 'number' then
        k = '"' .. k .. '"'
      end
      s = s .. '[' .. k .. '] = ' .. table_dump(v) .. ','
    end
    return s .. '} '
  else
    return tostring(orig)
  end
end

-- Shallow copy table contents. nested cloning does not work.
-- Implementation from here: http://lua-users.org/wiki/CopyTable
local function table_shallowcopy(orig)
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
    function plug.Install()
      vim.cmd(':PlugInstall')
    end

    return plug
  else
    return nil
  end
end

-- [[ Utility Variables ]] {{{1
local user_home = vim.fn.expand('~')

-- [[ Define functions for plugin setup ]] {{{1

-- [[ Generic lsp keymap setup ]] {{{2
local function lsp_keymaps_setup(args)
  local always_set = args.always_set or false
  local args_data = args.data or {}
  local client = vim.lsp.get_client_by_id(args_data.client_id)

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
      vim.notify('No ' .. options.title .. ' to jump to.', vim.log.levels.WARN)
    elseif #options.items == 1 then
      vim.api.nvim_command('cfirst')
    else
      vim.api.nvim_command('botright copen')
      vim.api.nvim_command('wincmd p')
      require('periscope.builtin').quickfix()
    end
  end

  -- These options are ignored in VScode, so we don't need to make a special
  -- case for excluding them.
  local references_lsp_options = { on_list = references_on_list }
  local location_lsp_options = { on_list = location_on_list }

  vim.keymap.set('n', '<leader>wa', function()
    vim.lsp.buf.add_workspace_folder()
  end, { buffer = args.buf, desc = '[w]orkspace [a]dd folder' })
  vim.keymap.set('n', '<leader>wr', function()
    vim.lsp.buf.remove_workspace_folder()
  end, { buffer = args.buf, desc = '[w]orkspace [r]emove folder' })
  vim.keymap.set('n', '<leader>wl', function()
    vim.print(vim.lsp.buf.list_workspace_folders())
  end, { buffer = args.buf, desc = '[w]orkspace [l]ist folders' })

  -- Start of keymaps that shadow existing keymaps

  -- Only redefine `K` keymap if current LSP supports hover capability.
  if always_set or client ~= nil and client.server_capabilities.hoverProvider then
    vim.keymap.set('n', 'K', function()
      vim.lsp.buf.hover()
    end, { buffer = args.buf, desc = 'Hover Popup' })
  end

  -- Explicitly set `tagfunc` to call `vim.lsp.tagfunc`. This is the lsp
  -- default anyway, but it's made explicit here.
  --
  -- By setting `tagfunc`, the `<C-]>` keybinding should work using the lsp
  -- server. `gd` is bound to `<C-]>` in `init.vim` as well.
  --
  -- Found originally at this link:
  -- https://www.reddit.com/r/neovim/comments/rpznbg/tip_use_formatexpr_and_tagfunc_with_lsp/
  --
  -- See also: `:h lsp-defaults`
  if always_set or client ~= nil and client.server_capabilities.definitionProvider then
    if args.buf ~= nil then
      vim.api.nvim_buf_set_option(args.buf, 'tagfunc', 'v:lua.vim.lsp.tagfunc')
    else
      vim.api.nvim_set_option('tagfunc', 'v:lua.vim.lsp.tagfunc')
    end
  end

  -- Explicitly set `formatexpr` to call `vim.lsp.formatexpr()`. This is the lsp
  -- default anyway, but it's made explicit here.
  --
  -- By setting `formatexpr`, the `gq` keybinding should work using the lsp
  -- server.
  --
  -- Found originally at this link:
  -- https://www.reddit.com/r/neovim/comments/rpznbg/tip_use_formatexpr_and_tagfunc_with_lsp/
  --
  -- See also: `:h lsp-defaults`
  -- if always_set or client ~= nil and client.server_capabilities.documentRangeFormattingProvider then
  --   vim.api.nvim_buf_set_option(args.buf, 'formatexpr', 'v:lua.vim.lsp.formatexpr()')
  -- end

  if args.buf then
    -- This will fallback to 'v:lua.vim.lsp.formatexpr()' if no other formatter
    -- is configured/found by conform.
    vim.bo[args.buf].formatexpr = "v:lua.require'conform'.formatexpr()"
  end

  -- References
  --
  -- Use the following link for reference on how to override the default
  -- references behavior.
  --
  -- https://github.com/pbogut/dotfiles/blob/7ba96f5871868c1ce02f4b3832c1659637fb0c2c/config/nvim/lua/plugins/nvim_lsp.lua#L88C1-L101C4
  if always_set or client ~= nil and client.server_capabilities.referencesProvider then
    local function references_func()
      vim.lsp.buf.references(nil, references_lsp_options)
    end

    -- `gr` is bound to `[I` in `init.vim`
    vim.keymap.set('n', '[I', references_func, { buffer = args.buf, desc = 'References' })
  end

  local function implementation_func()
    vim.lsp.buf.implementation(location_lsp_options)
  end
  vim.keymap.set('n', 'gi', implementation_func, { buffer = args.buf, desc = '[g]oto [i]mplementation' })

  vim.keymap.set('n', 'gD', function()
    vim.lsp.buf.declaration(location_lsp_options)
  end, { buffer = args.buf, desc = '[g]oto [D]eclaration' })

  vim.keymap.set('n', '<C-k>', function()
    vim.lsp.buf.signature_help()
  end, { buffer = args.buf, desc = 'Signature help' })

  local function type_definition_func()
    vim.lsp.buf.type_definition(location_lsp_options)
  end
  vim.keymap.set('n', 'gt', type_definition_func, { buffer = args.buf, desc = '[g]oto [t]ype definition' })

  -- telescope builtins

  vim.keymap.set('n', '<leader>sd', function()
    require('periscope.builtin').lsp_document_symbols()
  end, { buffer = args.buf, desc = '[s]earch [d]ocument symbols' })

  vim.keymap.set('n', '<leader>sw', function()
    require('periscope.builtin').lsp_dynamic_workspace_symbols()
  end, { buffer = args.buf, desc = '[s]earch [w]orkspace symbols' })

  -- custom keymaps using <leader> key
  vim.keymap.set('n', '<leader>rn', function()
    vim.lsp.buf.rename()
  end, { buffer = args.buf, desc = '[r]e[n]ame' })

  vim.keymap.set({ 'n', 'v' }, '<leader>ca', function()
    vim.lsp.buf.code_action()
  end, { buffer = args.buf, desc = '[c]ode [a]ction' })

  -- This is something different in vscode, but it is duplicated here so that it actually points to something
  vim.keymap.set({ 'n', 'v' }, '<leader>qf', function()
    vim.lsp.buf.code_action()
  end, { buffer = args.buf, desc = '[q]uick [f]ix (i.e. Code Action)' })

  -- Get capabilities of current LSP server
  vim.api.nvim_create_user_command('LspCapabilities', function()
    vim.print(vim.lsp.get_active_clients({ bufnr = vim.api.nvim_get_current_buf() })[1].server_capabilities)
  end, { desc = 'Print capabilities of current LSP server implementation.' })

  -- foldingRangeProvider
  -- Should ONLY be set in Neovim with a legitimate client.
  if client ~= nil and client.server_capabilities.documentHighlightProvider then
    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
      pattern = '<buffer>',
      callback = function()
        vim.lsp.buf.document_highlight()
      end,
    })
    vim.api.nvim_create_autocmd('CursorMoved', {
      pattern = '<buffer>',
      callback = function()
        vim.lsp.buf.clear_references()
      end,
    })
  end
end

-- [[ Configure VSCode ]] {{{2
local function vscode_setup()
  local vscode = require('vscode-neovim')

  -- Set vscode.notify as default notify function. See docs here:
  -- https://github.com/vscode-neovim/vscode-neovim?tab=readme-ov-file#vscodenotifymsg
  vim.notify = vscode.notify

  -- It doesn't seem like the commentary code linked below is necessary anymore
  -- https://github.com/vscode-neovim/vscode-neovim/wiki/Plugins#vim-commentary

  vim.keymap.set('n', ']d', function()
    vscode.call('editor.action.marker.next')
  end, { desc = 'Goto next diagnostic message' })

  vim.keymap.set('n', '[d', function()
    vscode.call('editor.action.marker.prev')
  end, { desc = 'Goto previous diagnostic message' })

  -- Act like vim signify and jump between diff changes in editor
  vim.keymap.set('n', ']c', function()
    vscode.call('workbench.action.editor.nextChange')
  end, { desc = 'Goto next diff change' })

  vim.keymap.set('n', '[c', function()
    vscode.call('workbench.action.editor.previousChange')
  end, { desc = 'Goto previous diff change' })

  lsp_keymaps_setup({ always_set = true })
end

-- [[ Configure Mason tool installer ]] {{{2
-- https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim
local function mason_tool_installer_setup()
  -- mason-tool-installer requires that mason be setup first.
  require('mason').setup()

  -- Be sure to install GFM (Github Flavored Markdown) extension for `mdformat`
  -- in the venv created by Mason.
  -- This allows for autoformatting tables, and along with other common extensions.
  --
  -- Also install the `mdformat-frontmatter` extension
  -- to allow frontmatter metadata used for writing blog posts.
  --
  -- Instructions for this can be found in the Github repo links below.
  --
  -- See links for details:
  -- * https://github.com/executablebooks/mdformat
  -- * https://github.com/hukkin/mdformat-gfm
  -- * https://mdformat.readthedocs.io/en/stable/users/style.html#paragraph-word-wrapping
  -- * https://pypi.org/project/mdformat_frontmatter/
  -- * https://github.com/butler54/mdformat-frontmatter
  require('mason-tool-installer').setup({

    -- a list of all tools you want to ensure are installed upon start
    ensure_installed = {
      'bash-language-server',
      'black',
      'codelldb',
      'codespell',
      'css-lsp',
      'dot-language-server',
      'gitlint',
      'html-lsp',
      'htmlhint',
      'java-debug-adapter',
      'java-test',
      'jdtls',
      'jq',
      'json-lsp',
      'jsonlint',
      'kotlin-language-server',
      'lemminx',
      'lemmy-help',
      'llm-ls',
      'lua-language-server',
      'luacheck', -- needs `luarocks` available to install
      'markdownlint',
      'mdformat',
      'prettier',
      'prettierd',
      'pylint',
      'pyright',
      'ruff',
      'shellcheck',
      'shfmt',
      'sqlfluff',
      'sqlfmt',
      'stylua',
      'taplo',
      'terraform-ls',
      'typescript-language-server',
      'vim-language-server',
      'vint',
      'write-good',
      'xmlformatter',
      'yaml-language-server',
      'yq',
      'zls',
    },

    -- if set to true this will check each tool for updates. If updates
    -- are available the tool will be updated. This setting does not
    -- affect :MasonToolsUpdate or :MasonToolsInstall.
    -- Default: false
    auto_update = false,

    -- automatically install / update on startup. If set to false nothing
    -- will happen on startup. You can use :MasonToolsInstall or
    -- :MasonToolsUpdate to install tools and check for updates.
    -- Default: true
    run_on_start = true,

    -- set a delay (in ms) before the installation starts. This is only
    -- effective if run_on_start is set to true.
    -- e.g.: 5000 = 5 second delay, 10000 = 10 second delay, etc...
    -- Default: 0
    -- start_delay = 3000, -- 3 second delay
  })
end

-- [[ Configure nvim-lint ]] {{{2
local function nvim_lint_setup()
  local lint = require('lint')

  lint.linters_by_ft = {
    bash = { 'bash', 'shellcheck' },
    gitcommit = { 'gitlint', 'write_good' },
    html = { 'htmlhint' },
    json5 = { 'json5' },
    ksh = { 'ksh', 'shellcheck' },
    lua = { 'luac', 'luacheck' },
    markdown = { 'markdownlint' },
    plantuml = { 'compiler' },
    python = { 'ruff' },
    rst = { 'write_good' },
    sh = { 'dash', 'shellcheck' },
    sql = { 'sqlfluff' },
    vim = { 'vint' },
    zsh = { 'zsh' },
  }

  local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })

  vim.api.nvim_create_autocmd({ 'InsertLeave', 'BufWritePost' }, {
    group = lint_augroup,
    callback = function()
      lint.try_lint()

      if not vim.g.disable_codespell_lint then
        -- Run codespell on all buffers of every filetype
        lint.try_lint('codespell')
      end
    end,
  })

  vim.keymap.set('n', '<leader>lf', function()
    lint.try_lint()
    lint.try_lint('codespell')
  end, { desc = '[l]int current [f]ile' })
end

-- [[ Configure conform ]] {{{2
local function conform_setup()
  local format_on_save_ft_configs = {
    ksh = { 'shfmt' },
    lua = { 'stylua' },
    mksh = { 'shfmt' },
    zig = { 'zigfmt' },
    zsh = { 'shfmt' },
  }

  local no_format_on_save_ft_configs = {
    ant = { 'xmlformat' },
    bash = { 'shfmt' },
    graphql = { 'prettier' },
    javascript = { 'prettier' },
    json = { 'jq' },
    markdown = { 'prettier' },
    python = { 'black', lsp_format = 'none' },
    sh = { 'shfmt' },
    sql = { 'sqlfluff' },
    svg = { 'xmlformat' },
    toml = { 'taplo' },
    typescript = { 'prettier' },
    xml = { 'xmlformat' },
    xsd = { 'xmlformat' },
    xsl = { 'xmlformat' },
    xslt = { 'xmlformat' },
    yaml = { 'yq' },
  }

  if vim.fn.executable('tofu') == 1 then
    -- probably on personal projects
    format_on_save_ft_configs.terraform = { 'tofu_fmt' }
  elseif vim.fn.executable('terraform') == 1 then
    -- probably on dayjob projects
    no_format_on_save_ft_configs.terraform = { 'terraform_fmt' }
  end

  local format_on_save_fts = vim.tbl_keys(format_on_save_ft_configs)

  local formatters_by_ft_all = vim.tbl_extend('error', format_on_save_ft_configs, no_format_on_save_ft_configs)

  require('conform').setup({
    -- log_level = vim.log.levels.DEBUG,
    formatters_by_ft = formatters_by_ft_all,
    formatters = {
      xmlformat = function(bufnr)
        return {
          prepend_args = {
            '--eof-newline',
            '--blanks',
            '--selfclose',
            '--indent',
            '4',
          },
        }
      end,
      prettier = function(bufnr)
        local filetype = vim.filetype.match({ buf = bufnr })
        local require_pragma = 'false'

        -- Uncomment to only format certain filetypes when pragma is present.
        -- if filetype == 'markdown' then
        --   require_pragma = 'true'
        -- end

        return {
          prepend_args = {
            '--prose-wrap=preserve',
            '--embedded-language-formatting=off',
            '--require-pragma',
            require_pragma,
          },
        }
      end,
      mdformat = function(bufnr)
        return {
          prepend_args = {
            '--number',
            '--wrap=keep',
          },
        }
      end,
      yq = function(bufnr)
        return {
          prepend_args = {
            '--unwrapScalar=false',
          },
        }
      end,

      -- TODO: Set the `--language-dialect` dynamically based on filetype.
      -- shfmt = {
      --   prepend_args = function (self, ctx)
      --     ctx.filetype
      --   end,
      -- },
    },

    -- Set this to change the default values when calling conform.format()
    -- This will also affect the default values for format_on_save/format_after_save
    default_format_opts = {
      lsp_format = 'last',
      stop_after_first = true,
      timeout_ms = 3000,
    },

    format_on_save = function(bufnr)
      if
          vim.b.conform_disable_autoformat
          -- Allow buffer local disable setting to always take precedence
          or (vim.b.conform_disable_autoformat == nil and vim.g.conform_disable_autoformat)
          or not vim.tbl_contains(format_on_save_fts, vim.bo[bufnr].filetype)
      then
        -- Returning `nil` disables autoformatting
        return nil
      else
        return { bufnr = bufnr }
      end
    end,
  })

  -- Explicitly set global `formatexpr` to call `require('conform').formatexpr()`.
  --
  -- By setting `formatexpr`, the `gq` keybinding should work using conform.
  vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

  vim.keymap.set({ 'n' }, '<leader>gq', function()
    require('conform').format()
  end, { desc = 'Format entire buffer. May produce different result than `gggqG`.' })
end

-- [[ Configure lsp ]] {{{2
local function lsp_config_setup()
  -- Setup neovim lua configuration
  -- IMPORTANT: make sure to setup neodev BEFORE lspconfig. See here:
  -- https://github.com/folke/neodev.nvim?tab=readme-ov-file#-setup
  require('neodev').setup()

  -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

  -- Using nvim-lspconfig plugin to quickly configure multiple LSPs with sane defaults. See links below.

  local xml_filetypes = { 'xml', 'xsd', 'xsl', 'xslt', 'svg', 'ant' }
  local lemminx_cfg = {
    filetypes = xml_filetypes,
  }

  -- Only add a global XML catalog if it can be found.
  local xml_catalog = user_home .. '/dev/catalog.xml'
  if vim.fn.filereadable(xml_catalog) then
    lemminx_cfg = {
      filetypes = xml_filetypes,
      xml = { catalogs = { xml_catalog } },
    }
  end

  -- These language servers will need to be installed somehow before being used.
  local servers = {
    lua_ls = {
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
    },

    -- https://cs.opensource.google/go/x/tools/+/refs/tags/gopls/v0.14.2:gopls/doc/vim.md#neovim
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#gopls
    -- Should work so long as `gopls` command is on $PATH
    gopls = {},

    -- for ruby
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#solargraph
    -- More documentation on using solargraph with bundler:
    -- https://github.com/castwide/solargraph?tab=readme-ov-file#solargraph-and-bundler
    solargraph = {
      cmd = { 'bundle', 'exec', 'solargraph', 'stdio' },
    },

    -- for ruby
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#ruby_lsp
    -- More documentation on using solargraph with bundler:
    -- https://github.com/castwide/solargraph?tab=readme-ov-file#solargraph-and-bundler
    ruby_lsp = {
      cmd = { 'bundle', 'exec', 'ruby-lsp' },

      -- Don't use eruby for now since it attempts to delegate to another LSP
      -- for HTML, which is VSCode behavior that doesn't exist in Neovim.
      -- filetypes = { 'ruby', 'eruby' },
      filetypes = { 'ruby' },
      init_options = {
        -- formatter = 'standard',
        formatter = 'rubocop',
        -- linters = { 'standard', 'rubocop' },
        linters = { 'rubocop' },
      },
    },

    -- for ruby
    -- sorbet = {
    --   cmd = { 'bundle', 'exec', 'srb', 'tc', '--lsp', '--disable-watchman' },
    -- },

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
    ts_ls = {},

    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#yamlls
    yamlls = {},

    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#lemminx
    lemminx = lemminx_cfg,

    -- for markdown
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#marksman
    -- marksman = {},

    -- for toml
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#taplo
    taplo = {},

    -- for terraform-ls
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#terraformls
    terraformls = {},

    -- for vimscript
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#vimls
    vimls = {},

    -- for zig
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#zls
    zls = {},

    -- bash shell scripts
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#bashls
    bashls = {
      filetypes = { 'sh', 'bash' },
    },

    -- Graphviz dot files
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#dotls
    dotls = {},

    -- Kotlin
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#kotlin_language_server
    kotlin_language_server = {},
  }

  local lspconfig = require('lspconfig')

  for server_name, opts in pairs(servers) do
    local lopts = table_shallowcopy(opts)
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
      vim.api.nvim_buf_create_user_command(0, 'JdtTestClass', function()
        require('jdtls').test_class()
      end, { desc = 'Test current class using Java JDT with DAP debugging capabilities enabled.' })

      vim.api.nvim_buf_create_user_command(0, 'JdtTestNearestMethod', function()
        require('jdtls').test_nearest_method()
      end, { desc = 'Test nearest method using Java JDT with DAP debugging capabilities enabled.' })

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
      -- * master branch: https://github.com/mfussenegger/nvim-jdtls/blob/master/README.md#data-directory-configuration
      -- * permalink: https://github.com/mfussenegger/nvim-jdtls/blob/99e4b2081de1d9162666cc7b563cbeb01c26b66b/README.md#data-directory-configuration

      -- If neovim was started within `~/dev/xy/project-1` this would resolve to `project-1`
      local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
      local workspace_dir = user_home .. '/tmp/jdtls/data/' .. project_name

      require('jdtls').start_or_attach({
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
      lsp_keymaps_setup(args)
    end,
  })
end

-- [[ Configure nvim-cmp ]] {{{2
-- See `:help cmp`
local function cmp_setup()
  local cmp = require('cmp')
  local luasnip = require('luasnip')
  require('luasnip.loaders.from_vscode').lazy_load()
  require('luasnip.loaders.from_snipmate').lazy_load()
  luasnip.config.setup({})

  cmp.setup({
    snippet = {
      expand = function(args)
        -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        luasnip.lsp_expand(args.body) -- For `luasnip` users.
        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
        -- vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-n>'] = cmp.mapping.select_next_item(),
      ['<C-p>'] = cmp.mapping.select_prev_item(),
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete({}),
      ['<CR>'] = cmp.mapping.confirm({
        behavior = cmp.ConfirmBehavior.Replace,
        select = false,
      }),
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
    }),
    sources = {
      -- { name = 'vsnip' },
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
      { name = 'buffer' },
      { name = 'path' },
      {
        name = 'rg',
        keyword_length = 3,
      },
      -- { name = 'cmdline' },
    },
  })

  -- -- `/` cmdline setup.
  -- cmp.setup.cmdline('/', {
  --   mapping = cmp.mapping.preset.cmdline(),
  --   sources = {
  --     { name = 'buffer' }
  --   }
  -- })

  -- -- `:` cmdline setup.
  -- cmp.setup.cmdline(':', {
  --   mapping = cmp.mapping.preset.cmdline(),
  --   sources = cmp.config.sources({
  --     {
  --       name = 'path',
  --       keyword_length = 3,
  --     }
  --   }, {
  --     {
  --       name = 'cmdline',
  --       keyword_length = 3,
  --     }
  --   }),
  --   matching = { disallow_symbol_nonprefix_matching = false }
  -- })
end

-- [[ Configure fidget ]] {{{2
local function fidget_setup()
  require('fidget').setup({
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
  require('periscope').setup(opts)

  -- Fuzzy keymaps
  vim.keymap.set('n', '<leader>ss', function()
    require('periscope.builtin').builtin()
  end, { desc = '[s]earch periscope [s]electors' })
  vim.keymap.set('n', '<leader>sb', function()
    require('periscope.builtin').buffers()
  end, { desc = '[s]earch [b]uffers' })
  vim.keymap.set('n', '<leader>sc', function()
    require('periscope.builtin').commands()
  end, { desc = '[s]earch [c]ommands' })
  vim.keymap.set('n', '<leader>sg', function()
    require('periscope.builtin').live_grep()
  end, { desc = '[s]earch file contents with [g]rep' })
  vim.keymap.set('n', '<leader>sh', function()
    require('periscope.builtin').help_tags()
  end, { desc = '[s]earch [h]elp tags' })
  vim.keymap.set('n', '<leader>sk', function()
    require('periscope.builtin').keymaps()
  end, { desc = '[s]earch [k]eymaps' })
  vim.keymap.set('n', '<leader>sp', function()
    require('periscope.builtin').find_files()
  end, { desc = '[s]earch project [p]aths' })
  vim.keymap.set('n', '<leader>so', function()
    require('periscope.builtin').oldfiles()
  end, { desc = '[s]earch [o]ld files opened previously' })
  vim.keymap.set('n', '<leader>sv', function()
    require('periscope.builtin').git_files()
  end, { desc = '[s]earch [v]ersion controlled file paths' })
  vim.keymap.set('n', '<leader>sj', function()
    require('periscope.builtin').jumplist()
  end, { desc = '[s]earch periscope [j]umplist' })
  vim.keymap.set('n', 'z=', function()
    require('periscope.builtin').spell_suggest()
  end, { desc = 'Spell suggestions' })
end

-- [[ Configure DAP ]] {{{2
local function dap_setup()
  vim.keymap.set('n', '<F1>', function()
    require('dap').step_out()
  end, { desc = 'DAP step out' })
  vim.keymap.set('n', '<F2>', function()
    require('dap').step_into()
  end, { desc = 'DAP step into' })
  vim.keymap.set('n', '<F3>', function()
    require('dap').step_over()
  end, { desc = 'DAP step over' })
  vim.keymap.set('n', '<F4>', function()
    require('dap').continue()
  end, { desc = 'DAP continue' })
  vim.keymap.set('n', '<leader>b', function()
    require('dap').toggle_breakpoint()
  end, { desc = 'DAP toggle breakpoint' })
  vim.keymap.set('n', '<leader>B', function()
    require('dap').set_breakpoint()
  end, { desc = 'DAP set breakpoint' })
  vim.keymap.set('n', '<leader>dm', function()
    require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
  end, { desc = 'DAP Log point message' })
  vim.keymap.set('n', '<leader>dr', function()
    require('dap').repl.open()
  end, { desc = 'DAP REPL open' })
  vim.keymap.set('n', '<leader>dl', function()
    require('dap').run_last()
  end, { desc = 'DAP run last' })

  vim.keymap.set({ 'n', 'v' }, '<leader>dh', function()
    require('dap.ui.widgets').hover()
  end, { desc = 'DAP UI hover' })
  vim.keymap.set({ 'n', 'v' }, '<leader>dp', function()
    require('dap.ui.widgets').preview()
  end, { desc = 'DAP UI preview' })
  vim.keymap.set('n', '<leader>df', function()
    local widgets = require('dap.ui.widgets')
    widgets.centered_float(widgets.frames)
  end, { desc = 'DAP UI centered float frames' })
  vim.keymap.set('n', '<leader>ds', function()
    local widgets = require('dap.ui.widgets')
    widgets.centered_float(widgets.scopes)
  end, { desc = 'DAP UI centered float scopes' })

  local dap = require('dap')
  local dapui = require('dapui')
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

  -- local dap_ruby = require('dap-ruby')
  -- dap_ruby.setup()

  dap.adapters.ruby = function(callback, config)
    callback({
      type = 'server',
      host = '127.0.0.1',
      port = '${port}',
      executable = {
        command = 'bundle',
        args = {
          'exec',
          'rdbg',
          '-n',
          '--open',
          '--port',
          '${port}',
          '-c',
          '--',
          'bundle',
          'exec',
          config.command,
          config.script,
        },
      },
    })
  end

  dap.configurations.ruby = {
    {
      type = 'ruby',
      name = 'debug current file',
      request = 'attach',
      localfs = true,
      command = 'ruby',
      script = '${file}',
    },
    {
      type = 'ruby',
      name = 'run current spec file',
      request = 'attach',
      localfs = true,
      command = 'rspec',
      script = '${file}',
    },
    {
      type = 'ruby',
      name = 'run default rake task',
      request = 'attach',
      localfs = true,
      command = 'rake',
      script = 'default',
    },
  }

  local function codelldb_setup(filetype, opts)
    if not dap.adapters.codelldb then
      -- Configuration originally from:
      -- https://github.com/mfussenegger/nvim-dap/wiki/C-C---Rust-%28via--codelldb%29

      -- codelldb can be used for most natively compiled code with debugging symbols present.
      dap.adapters.codelldb = {
        type = 'executable',
        command = 'codelldb',

        -- On windows you may have to uncomment this:
        -- detached = false,
      }
    end

    opts = opts or {}

    if not dap.configurations[filetype] then
      dap.configurations[filetype] = {
        {
          name = opts.name or 'Launch file',
          type = opts.type or 'codelldb',
          request = opts.request or 'launch',
          program = opts.program or function()
            return vim.fn.input({
              prompt = 'Path to executable: ',
              default = vim.fn.getcwd() .. '/',
              completion = 'file',
            })
          end,
          cwd = opts.cwd or '${workspaceFolder}',
          stopOnEntry = opts.stopOnEntry or false,
        },
      }
    end
  end

  local codelldb_filetypes = {
    c = {},
    cpp = {},
    rust = {},
    zig = {
      -- zig executables are in well known locations, just list those instead
      -- of asking for a full path from the user, like is done for c, cpp,
      -- and rust.
      program = function()
        local root = vim.fn.getcwd()

        local execs = vim.fn.glob(root .. '/zig-out/bin/*', false, true)
        local test_execs = vim.fn.glob(root .. '/.zig-cache/o/*/test', false, true)

        local all_paths = {}

        vim.list_extend(all_paths, execs)
        vim.list_extend(all_paths, test_execs)

        local for_display = { 'Select executable:' }

        for index, value in ipairs(all_paths) do
          table.insert(for_display, string.format('%d. %s', index, value))
        end

        -- See here for synchronous picker in dap:
        -- https://github.com/mfussenegger/nvim-dap/blob/66d33b7585b42b7eac20559f1551524287ded353/lua/dap/ui.lua#L55
        -- Use this instead of vim.fn.inputlist, which cannot be replaced or themed.
        --
        -- local response = dap.ui.pick_one(all_paths, "Select executable", tostring, nil)
        -- local result = response[1]
        -- local index = response[2]

        local choice = vim.fn.inputlist(for_display)
        local final_choice = all_paths[choice]

        vim.print(choice)
        vim.print(final_choice)

        return final_choice
      end,
    },
  }

  -- Lazily setup codelldb for dap when encountering supported filetypes.
  -- for _, ft in ipairs(codelldb_filetypes) do
  for ft, ftopts in pairs(codelldb_filetypes) do
    vim.api.nvim_create_autocmd('FileType', {
      pattern = ft,
      group = vim.api.nvim_create_augroup('DapCodelldbConfig_' .. ft, { clear = true }),
      callback = function()
        codelldb_setup(ft, ftopts)
      end,
    })
  end
end

-- [[ Configure Dressing ]] {{{2
local function dressing_setup()
  -- https://github.com/stevearc/dressing.nvim?tab=readme-ov-file#configuration
  require('dressing').setup({
    select = {
      -- Options for telescope selector
      -- These are passed into the telescope picker directly. Can be used like:
      -- telescope = require('telescope.themes').get_ivy({...})
      telescope = require('telescope.themes').get_ivy({ include_current_line = true }),
    },
  })
end

-- [[ Configure llm.nvim ]] {{{2
local function llm_setup()
  require('gen').setup({
    model = 'mistral',      -- The default model to use.
    quit_map = 'q',         -- set keymap to close the response window
    retry_map = '<c-r>',    -- set keymap to re-send the current prompt
    accept_map = '<c-cr>',  -- set keymap to replace the previous selection with the last result
    host = 'localhost',     -- The host running the Ollama service.
    port = '11434',         -- The port on which the Ollama service is listening.
    display_mode = 'split', -- The display mode. Can be "float" or "split" or "horizontal-split".
    show_prompt = true,     -- Shows the prompt submitted to Ollama. Can be true (3 lines) or "full".
    show_model = true,      -- Displays which model you are using at the beginning of your chat session.
    no_auto_close = false,  -- Never closes the window automatically.
    file = true,            -- Write the payload to a temporary file to keep the command short.
    hidden = false,         -- Hide the generation window (if true, will implicitly set `prompt.replace = true`), requires Neovim >= 0.10
    init = function(options)
      pcall(io.popen, 'ollama serve > /dev/null 2>&1 &')
    end,
    -- Function to initialize Ollama
    command = function(options)
      local body = { model = options.model, stream = true }
      return 'curl --silent --no-buffer -X POST http://' .. options.host .. ':' .. options.port .. '/api/chat -d $body'
    end,
    -- The command for the Ollama service. You can use placeholders $prompt, $model and $body (shellescaped).
    -- This can also be a command string.
    -- The executed command must return a JSON object with { response, context }
    -- (context property is optional).
    -- list_models = '<omitted lua function>', -- Retrieves a list of model names
    result_filetype = 'markdown', -- Configure filetype of the result buffer
    debug = false,                -- Prints errors and the command which is run.
  })
end

-- [[ Configure telescope ]] {{{2
local function telescope_setup()
  require('telescope').setup({})
end

-- [[ Configure Treesitter ]] {{{2
local function treesitter_setup()
  require('nvim-treesitter.configs').setup({
    modules = {},        -- Added to silence linter
    ignore_install = {}, -- Added to silence linter

    -- A list of parser names, or "all" (the five listed parsers should always be installed)
    ensure_installed = { 'lua', 'vim', 'vimdoc', 'query' },

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

    textobjects = {
      select = {
        enable = true,

        -- Automatically jump forward to textobj, similar to targets.vim
        lookahead = true,

        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['af'] = { query = '@function.outer', desc = 'Select around a function region' },
          ['if'] = { query = '@function.inner', desc = 'Select inner part of a function region' },
          ['ak'] = { query = '@class.outer', desc = 'Select around a class region' },
          -- You can optionally set descriptions to the mappings (used in the desc parameter of
          -- nvim_buf_set_keymap) which plugins like which-key display
          ['ik'] = { query = '@class.inner', desc = 'Select inner part of a class region' },
          -- You can also use captures from other query groups like `locals.scm`
          -- ['as'] = { query = '@local.scope', query_group = 'locals', desc = 'Select language scope' },
        },
        -- You can choose the select mode (default is charwise 'v')
        --
        -- Can also be a function which gets passed a table with the keys
        -- * query_string: eg '@function.inner'
        -- * method: eg 'v' or 'o'
        -- and should return the mode ('v', 'V', or '<c-v>') or a table
        -- mapping query_strings to modes.
        selection_modes = {
          ['@parameter.outer'] = 'v', -- charwise
          ['@function.outer'] = 'V',  -- linewise
          ['@class.outer'] = '<c-v>', -- blockwise
        },
        -- If you set this to `true` (default is `false`) then any textobject is
        -- extended to include preceding or succeeding whitespace. Succeeding
        -- whitespace has priority in order to act similarly to eg the built-in
        -- `ap`.
        --
        -- Can also be a function which gets passed a table with the keys
        -- * query_string: eg '@function.inner'
        -- * selection_mode: eg 'v'
        -- and should return true or false
        include_surrounding_whitespace = true,
      },
    },

    -- Use Neovim for pair matching
    matchup = {
      enable = true, -- mandatory, false will disable the whole extension
    },
  })

  local parser_config = require('nvim-treesitter.parsers').get_parser_configs()

  parser_config.gotmpl = {
    install_info = {
      url = 'https://github.com/ngalaiko/tree-sitter-go-template',
      files = { 'src/parser.c' },
    },
    filetype = 'gotmpl',
    used_by = { 'gohtmltmpl', 'gotexttmpl', 'gotmpl' },
  }

  vim.o.foldmethod = 'expr'
  vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
  vim.o.foldlevel = 99
end

-- [[ Configure Keymaps for nvim only ]] {{{2
-- See `:help vim.keymap.set()`
local function general_neovim_setup()
  -- [[ Keymaps ]] {{{3
  vim.keymap.set('n', '<leader>nf', function()
    vim.diagnostic.open_float()
  end, { desc = 'Open diag[n]ostic [f]loat' })

  vim.keymap.set('n', '[d', function()
    vim.diagnostic.goto_prev({ wrap = false })
  end, { desc = 'Goto previous diagnostic message' })

  vim.keymap.set('n', ']d', function()
    vim.diagnostic.goto_next({ wrap = false })
  end, { desc = 'Goto next diagnostic message' })

  vim.keymap.set('n', '<leader>nl', function()
    vim.diagnostic.setloclist()
  end, { desc = 'Open diag[n]ostics in [l]ocation list' })

  vim.keymap.set('n', '<leader>nq', function()
    vim.diagnostic.setqflist()
  end, { desc = 'Open diag[n]ostics in [q]uickfix list' })

  vim.keymap.set('n', '<space>na', function()
    for _, client in ipairs(vim.lsp.get_clients()) do
      require('workspace-diagnostics').populate_workspace_diagnostics(client, 0)
    end
  end, { desc = 'Populate diag[n]ostics for files in [a]ll LSP workspaces' })

  -- [[ diagnostics config ]] {{{3
  local dconfig = vim.diagnostic.config()

  dconfig.severity_sort = true
  dconfig.float = {
    severity_sort = true,
    source = true,
  }

  vim.diagnostic.config(dconfig)

  -- Code below taken from Nvim diagnostics help page.

  -- Create a custom namespace. This will aggregate signs from all other
  -- namespaces and only show the one with the highest severity on a
  -- given line
  local ns = vim.api.nvim_create_namespace('my_namespace')

  -- Get a reference to the original signs handler
  local orig_signs_handler = vim.diagnostic.handlers.signs

  -- Override the built-in signs handler
  vim.diagnostic.handlers.signs = {
    show = function(_, bufnr, _, opts)
      -- Get all diagnostics from the whole buffer rather than just the
      -- diagnostics passed to the handler
      local diagnostics = vim.diagnostic.get(bufnr)

      -- Find the "worst" diagnostic per line
      local max_severity_per_line = {}
      for _, d in pairs(diagnostics) do
        local m = max_severity_per_line[d.lnum]
        if not m or d.severity < m.severity then
          max_severity_per_line[d.lnum] = d
        end
      end

      -- Pass the filtered diagnostics (with our custom namespace) to
      -- the original handler
      local filtered_diagnostics = vim.tbl_values(max_severity_per_line)
      orig_signs_handler.show(ns, bufnr, filtered_diagnostics, opts)
    end,
    hide = function(_, bufnr)
      orig_signs_handler.hide(ns, bufnr)
    end,
  }

  -- Show marks in sign column
  -- Also adds some useful kebindings for working with Marks
  require('marks').setup()
end

-- [[ Run all setup functions ]] {{{1

-- Lua does not guarantee order of string keys,
-- so it must be tracked in an array style table separately
-- if strict order is required,
-- as it is here.
--
-- Out of order evaluation can cause plugins to fail.
local init_funcs_keys = {
  'VSCode',
  'mason tool installer',
  'periscope',
  'conform',
  'fidget',
  'general Neovim',
  'lsp config',
  'cmp and snippet engine',
  'treesitter',
  'dap',
  'telescope',
  'dressing',
  'lint',
  'llm',
}

local init_funcs_all = {
  ['VSCode'] = { func = vscode_setup, vscode_only = true },
  ['mason tool installer'] = { func = mason_tool_installer_setup, everywhere = true },
  periscope = { func = periscope_setup, vscode_never = true },
  conform = { func = conform_setup, everywhere = true },
  fidget = { func = fidget_setup, vscode_never = true },
  ['general Neovim'] = { func = general_neovim_setup, vscode_never = true },
  ['lsp config'] = { func = lsp_config_setup, vscode_never = true },
  ['cmp and snippet engine'] = { func = cmp_setup, vscode_never = true },
  treesitter = { func = treesitter_setup, vscode_never = true },
  dap = { func = dap_setup, vscode_never = true },
  telescope = { func = telescope_setup, vscode_never = true },
  dressing = { func = dressing_setup, vscode_never = true },
  lint = { func = nvim_lint_setup, vscode_never = true },
  llm = { func = llm_setup, vscode_never = true },
}

for _, setup_name in ipairs(init_funcs_keys) do
  local setup_opts = init_funcs_all[setup_name]
  local should_run_func = (
    setup_opts.everywhere
    or (setup_opts.vscode_only and vim.g.vscode)
    or (setup_opts.vscode_never and not vim.g.vscode)
  )
  if should_run_func then
    local setup_succeed, setup_err = pcall(setup_opts.func)
    if not setup_succeed then
      vim.notify(
        string.format('%s setup failed. Check nvim config based on errors: %s', setup_name, setup_err),
        vim.log.levels.ERROR
      )
    end
  end
end

-- Force lspconfig to work properly with filetype detection. See this link:
-- https://www.reddit.com/r/neovim/comments/14cikep/comment/jokw2j6/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
vim.api.nvim_exec_autocmds('FileType', {})
