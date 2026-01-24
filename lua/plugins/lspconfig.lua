return {
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'j-hui/fidget.nvim', opts = {} },

    'saghen/blink.cmp',
  },
  config = function()
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup(
        'kickstart-lsp-attach',
        { clear = true }
      ),
      callback = function(event)
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

        map(
          'gra',
          vim.lsp.buf.code_action,
          '[G]oto Code [A]ction',
          { 'n', 'x' }
        )

        map(
          'grr',
          require('telescope.builtin').lsp_references,
          '[G]oto [R]eferences'
        )

        map(
          'gri',
          require('telescope.builtin').lsp_implementations,
          '[G]oto [I]mplementation'
        )

        map(
          'grd',
          require('telescope.builtin').lsp_definitions,
          '[G]oto [D]efinition'
        )

        map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        map(
          'gO',
          require('telescope.builtin').lsp_document_symbols,
          'Open Document Symbols'
        )

        map(
          'gW',
          require('telescope.builtin').lsp_dynamic_workspace_symbols,
          'Open Workspace Symbols'
        )

        map(
          'grt',
          require('telescope.builtin').lsp_type_definitions,
          '[G]oto [T]ype Definition'
        )

        local function client_supports_method(client, method, bufnr)
          if vim.fn.has 'nvim-0.11' == 1 then
            return client:supports_method(method, bufnr)
          else
            return client.supports_method(method, { bufnr = bufnr })
          end
        end

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if
            client
            and client_supports_method(
              client,
              vim.lsp.protocol.Methods.textDocument_documentHighlight,
              event.buf
            )
        then
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
            group = vim.api.nvim_create_augroup(
              'kickstart-lsp-detach',
              { clear = true }
            ),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds {
                group = 'kickstart-lsp-highlight',
                buffer = event2.buf,
              }
            end,
          })
        end

        if
            client
            and client_supports_method(
              client,
              vim.lsp.protocol.Methods.textDocument_inlayHint,
              event.buf
            )
        then
          map('<leader>tH', function()
            vim.lsp.inlay_hint.enable(
              not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }
            )
          end, '[T]oggle Inlay [H]ints')
        end
      end,
    })

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
          local diagnostic_message = {
            [vim.diagnostic.severity.ERROR] = diagnostic.message,
            [vim.diagnostic.severity.WARN] = diagnostic.message,
            [vim.diagnostic.severity.INFO] = diagnostic.message,
            [vim.diagnostic.severity.HINT] = diagnostic.message,
          }
          return diagnostic_message[diagnostic.severity]
        end,
      },
    }

    local capabilities = require('blink.cmp').get_lsp_capabilities()

    -- Function to load project-specific LSP overrides
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

    -- LSP server configurations mapped to their filetypes
    local servers = {
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

    -- Load and merge project-specific overrides
    local project_overrides = load_project_overrides()
    for lsp_name, override_config in pairs(project_overrides) do
      if servers[lsp_name] then
        -- Merge with existing server config
        servers[lsp_name] = vim.tbl_deep_extend(
          'force',
          servers[lsp_name],
          override_config
        )
      else
        -- Add new server config
        servers[lsp_name] = override_config
      end
    end

    -- Track which servers have been set up
    local setup_done = {}

    -- Function to setup a server using the new vim.lsp.config API (nvim 0.11+)
    local function setup_server(lsp_name)
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

    -- Create FileType autocommands for lazy server setup
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

    local lsp_lazy_load_group =
        vim.api.nvim_create_augroup('lsp-lazy-load', { clear = true })

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
  end,
}
