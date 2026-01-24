return {
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'j-hui/fidget.nvim', opts = {} },
    'saghen/blink.cmp',
  },
  config = function()
    -- ============================================================================
    -- Helper Functions
    -- ============================================================================

    -- Check if client supports a method (compatible with nvim 0.10 and 0.11+)
    local function client_supports_method(client, method, bufnr)
      if vim.fn.has 'nvim-0.11' == 1 then
        return client:supports_method(method, bufnr)
      else
        return client.supports_method(method, { bufnr = bufnr })
      end
    end

    -- ============================================================================
    -- LSP Keymaps Configuration
    -- ============================================================================

    local function setup_lsp_keymaps(event)
      local map = function(keys, func, desc, mode)
        mode = mode or 'n'
        vim.keymap.set(
          mode,
          keys,
          func,
          { buffer = event.buf, desc = 'LSP: ' .. desc }
        )
      end

      map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
      map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
      map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
      map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
      map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
      map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
      map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')
      map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
      map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')
    end

    -- ============================================================================
    -- Document Highlighting Setup
    -- ============================================================================

    local function setup_document_highlighting(client, event)
      if not client_supports_method(
          client,
          vim.lsp.protocol.Methods.textDocument_documentHighlight,
          event.buf
        ) then
        return
      end

      local highlight_augroup = vim.api.nvim_create_augroup(
        'kickstart-lsp-highlight',
        { clear = false }
      )

      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds {
            group = 'kickstart-lsp-highlight',
            buffer = event2.buf,
          }
        end,
      })
    end

    -- ============================================================================
    -- Inlay Hints Setup
    -- ============================================================================

    local function setup_inlay_hints(client, event)
      if not client_supports_method(
          client,
          vim.lsp.protocol.Methods.textDocument_inlayHint,
          event.buf
        ) then
        return
      end

      vim.keymap.set('n', '<leader>tH', function()
        vim.lsp.inlay_hint.enable(
          not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }
        )
      end, { buffer = event.buf, desc = 'LSP: [T]oggle Inlay [H]ints' })
    end

    -- ============================================================================
    -- Diagnostic Configuration
    -- ============================================================================

    local function configure_diagnostics()
      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = {
          source = 'if_many',
          spacing = 2,
          format = function(diagnostic)
            return diagnostic.message
          end,
        },
      }
    end

    -- ============================================================================
    -- Project Override Loading
    -- ============================================================================

    local function load_project_overrides()
      local override_file = vim.fn.getcwd() .. '/.nvim/lspconfig.lua'
      if vim.fn.filereadable(override_file) == 1 then
        local ok, overrides = pcall(dofile, override_file)
        if ok and type(overrides) == 'table' then
          vim.notify(
            'Loaded LSP overrides from .nvim/lspconfig.lua',
            vim.log.levels.INFO
          )
          return overrides
        else
          vim.notify(
            'Failed to load LSP overrides from ' .. override_file,
            vim.log.levels.WARN
          )
        end
      end
      return {}
    end

    -- ============================================================================
    -- Server Configurations
    -- ============================================================================

    local function get_server_configs()
      return {
        intelephense = {
          config = {
            cmd = { 'intelephense', '--stdio' },
            filetypes = { 'php' },
          },
        },

        ruff = {
          config = {
            filetypes = { 'python' },
          },
        },

        pyright = {
          config = {
            filetypes = { 'python' },
            root_markers = { 'pyproject.toml', 'setup.py' },
            settings = {
              pyright = {
                disableOrganizeImports = true,
              },
              python = {
                analysis = {
                  ignore = { '*' },
                },
              },
            },
          },
        },

        lua_ls = {
          config = {
            root_markers = { 'init.lua' },
            filetypes = { 'lua' },
            settings = {
              Lua = {
                completion = {
                  callSnippet = 'Replace',
                },
              },
            },
          },
        },
      }
    end

    -- ============================================================================
    -- Server Setup Functions
    -- ============================================================================

    local function merge_server_configs(servers, project_overrides)
      for lsp_name, override_config in pairs(project_overrides) do
        if servers[lsp_name] then
          servers[lsp_name] = vim.tbl_deep_extend('force', servers[lsp_name], override_config)
        else
          servers[lsp_name] = override_config
        end
      end
      return servers
    end

    local function create_server_setup_function(servers, capabilities)
      local setup_done = {}

      return function(lsp_name)
        if setup_done[lsp_name] then
          return
        end

        local lsp_config = servers[lsp_name]
        if not lsp_config then
          return
        end

        local config = vim.tbl_deep_extend('force', {}, lsp_config.config or {})
        config.capabilities = vim.tbl_deep_extend(
          'force',
          {},
          capabilities,
          config.capabilities or {}
        )

        -- Use new vim.lsp.config API for nvim 0.11+
        vim.lsp.config[lsp_name] = config
        vim.lsp.enable(lsp_name)

        setup_done[lsp_name] = true
      end
    end

    local function build_filetype_server_map(servers)
      local filetype_to_servers = {}
      for lsp_name, lsp_config in pairs(servers) do
        local filetypes = lsp_config.config.filetypes
        if filetypes then
          for _, ft in ipairs(filetypes) do
            if not filetype_to_servers[ft] then
              filetype_to_servers[ft] = {}
            end
            table.insert(filetype_to_servers[ft], lsp_name)
          end
        end
      end
      return filetype_to_servers
    end

    local function setup_lazy_loading(filetype_to_servers, setup_server)
      local lsp_lazy_load_group = vim.api.nvim_create_augroup('lsp-lazy-load', { clear = true })

      for ft, server_list in pairs(filetype_to_servers) do
        vim.api.nvim_create_autocmd('FileType', {
          pattern = ft,
          callback = function()
            for _, lsp_name in ipairs(server_list) do
              setup_server(lsp_name)
            end
          end,
          group = lsp_lazy_load_group,
        })
      end
    end

    -- ============================================================================
    -- Main Configuration
    -- ============================================================================

    -- Setup LspAttach autocmd for keymaps and features
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        setup_lsp_keymaps(event)

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client then
          setup_document_highlighting(client, event)
          setup_inlay_hints(client, event)
        end
      end,
    })

    -- Configure diagnostics
    configure_diagnostics()

    -- Get capabilities from blink.cmp
    local capabilities = require('blink.cmp').get_lsp_capabilities()

    -- Load and merge server configurations
    local servers = get_server_configs()
    local project_overrides = load_project_overrides()
    servers = merge_server_configs(servers, project_overrides)

    -- Setup server loading
    local setup_server = create_server_setup_function(servers, capabilities)
    local filetype_to_servers = build_filetype_server_map(servers)
    setup_lazy_loading(filetype_to_servers, setup_server)
  end,
}
