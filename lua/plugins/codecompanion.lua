return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'ravitemer/mcphub.nvim',
  },
  opts = {
    extensions = {
      mcphub = {
        callback = "mcphub.extensions.codecompanion",
        opts = {
          make_vars = true,
          make_slash_commands = true,
          show_result_in_chat = true
        }
      }
    },
    interactions = {
      chat = {
        tools = {
          opts = {
            auto_submit_errors = true,
            auto_submit_success = true,
            default_tools = {
              'cmd_runner',
              'create_file',
              'delete_file',
              'fetch_webpage',
              'file_search',
              'files',
              'full_stack_dev',
              'get_changed_files',
              'grep_search',
              'insert_edit_into_file',
              'list_code_usages',
              'memory',
              'next_edit_suggestion',
              'read_file',
              'web_search',
            }
          },
        },
        adapter = os.getenv 'ANTHROPIC_API_KEY' and 'anthropic' or 'copilot',
        model = 'claude-sonnet-4-20250514',
      },
    },
    -- note: the log_level is in `opts.opts`
    opts = {
      log_level = 'debug',
    },
    display = {
      diff = {
        provider_opts = {
          inline = {
            layout = 'buffer', -- float|buffer - Where to display the diff
            opts = {
              context_lines = 3, -- Number of context lines in hunks
            },
          },
        },
      },
    },
  },
  keys = {
    {
      '<leader>aa',
      '<cmd>CodeCompanionActions<cr>',
      mode = { 'n', 'v' },
      desc = 'CodeCompanion Actions',
    },
    {
      '<leader>at',
      '<cmd>CodeCompanionChat Toggle<cr>',
      mode = { 'n', 'v' },
      desc = 'Toggle CodeCompanion Chat',
    },
    {
      '<leader>ac',
      '<cmd>CodeCompanionChat<cr>',
      mode = { 'n', 'v' },
      desc = 'Open CodeCompanion Chat',
    },
    {
      'ga',
      '<cmd>CodeCompanionChat Add<cr>',
      mode = 'v',
      desc = 'Add selection to CodeCompanion',
    }, -- Note: Overrides built-in 'ga' (print ASCII)
  },
}
