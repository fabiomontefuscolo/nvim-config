return {
  "neovim/nvim-lspconfig",
  dependencies = {
    { "mason-org/mason.nvim", opts = {} },
    "mason-org/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",

    { "j-hui/fidget.nvim",    opts = {} },

    "saghen/blink.cmp",
  },
  config = function()
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc, mode)
          mode = mode or "n"
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
        end

        map("grn", vim.lsp.buf.rename, "[R]e[n]ame")

        map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })

        map("grr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

        map("gri", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

        map("grd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

        map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

        map("gO", require("telescope.builtin").lsp_document_symbols, "Open Document Symbols")

        map("gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Open Workspace Symbols")

        map("grt", require("telescope.builtin").lsp_type_definitions, "[G]oto [T]ype Definition")

        local function client_supports_method(client, method, bufnr)
          if vim.fn.has("nvim-0.11") == 1 then
            return client:supports_method(method, bufnr)
          else
            return client.supports_method(method, { bufnr = bufnr })
          end
        end

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if
            client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf)
        then
          local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd("LspDetach", {
            group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
            end,
          })
        end

        if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
          map("<leader>tH", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
          end, "[T]oggle Inlay [H]ints")
        end
      end,
    })

    vim.diagnostic.config({
      severity_sort = true,
      float = { border = "rounded", source = "if_many" },
      underline = { severity = vim.diagnostic.severity.ERROR },
      signs = vim.g.have_nerd_font and {
        text = {
          [vim.diagnostic.severity.ERROR] = "󰅚 ",
          [vim.diagnostic.severity.WARN] = "󰀪 ",
          [vim.diagnostic.severity.INFO] = "󰋽 ",
          [vim.diagnostic.severity.HINT] = "󰌶 ",
        },
      } or {},
      virtual_text = {
        source = "if_many",
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
    })

    local capabilities = require("blink.cmp").get_lsp_capabilities()

    -- LSP server configurations mapped to their filetypes
    local servers = {
      intelephense = {
        filetypes = { "php" },
        config = {},
      },

      ruff = {
        filetypes = { "python" },
        config = {},
      },

      pyright = {
        filetypes = { "python" },
        config = {
          root_dir = vim.fs.root(0, { "pyproject.toml", "setup.py", ".git", vim.fn.getcwd() }),
          settings = {
            pyright = {
              disableOrganizeImports = true,
            },
            python = {
              analysis = {
                ignore = { "*" },
              },
            },
          },
        },
      },

      lua_ls = {
        filetypes = { "lua" },
        config = {
          settings = {
            Lua = {
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        },
      },
    }

    -- Track which servers have been set up
    local setup_servers = {}

    -- Function to setup a server
    local function setup_server(server_name)
      if setup_servers[server_name] then
        return
      end

      local server_config = servers[server_name]
      if not server_config then
        return
      end

      local config = vim.tbl_deep_extend("force", {}, server_config.config or {})
      config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, config.capabilities or {})

      -- Set filetypes explicitly
      if server_config.filetypes then
        config.filetypes = server_config.filetypes
      end

      require("lspconfig")[server_name].setup(config)
      setup_servers[server_name] = true
    end

    -- -- Only ensure non-LSP tools are installed
    -- require("mason-tool-installer").setup({
    --   ensure_installed = {
    --     "stylua", -- Lua formatter
    --   },
    -- })

    -- Enable automatic installation when a filetype is opened
    require("mason-lspconfig").setup({
      ensure_installed = {},         -- Don't install anything upfront
      automatic_installation = true, -- Auto-install when needed
      handlers = {
        function(server_name)
          setup_server(server_name)
        end,
      },
    })

    -- Create FileType autocommands for lazy server setup
    local filetype_to_servers = {}
    for server_name, server_config in pairs(servers) do
      if server_config.filetypes then
        for _, ft in ipairs(server_config.filetypes) do
          if not filetype_to_servers[ft] then
            filetype_to_servers[ft] = {}
          end
          table.insert(filetype_to_servers[ft], server_name)
        end
      end
    end

    for ft, server_list in pairs(filetype_to_servers) do
      vim.api.nvim_create_autocmd("FileType", {
        pattern = ft,
        callback = function()
          for _, server_name in ipairs(server_list) do
            -- Check if server is installed via mason
            local registry = require("mason-registry")
            if registry.is_installed(server_name) then
              setup_server(server_name)
            else
              -- Trigger mason-lspconfig to install it
              vim.notify("Installing LSP server: " .. server_name, vim.log.levels.INFO)
            end
          end
        end,
        group = vim.api.nvim_create_augroup("lsp-lazy-load", { clear = true }),
      })
    end
  end,
}
