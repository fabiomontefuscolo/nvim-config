return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'ravitemer/mcphub.nvim',
  },
  opts = {
    interactions = {
      chat = {
        adapter = os.getenv 'ANTHROPIC_API_KEY' and 'anthropic' or 'copilot',
        model = 'claude-sonnet-4-20250514',
      },
    },
    -- note: the log_level is in `opts.opts`
    opts = {
      log_level = 'debug',
    },
  },
  keys = {
    { '<leader>aa', '<cmd>CodeCompanionActions<cr>', mode = { 'n', 'v' }, desc = 'CodeCompanion Actions' },
    { '<leader>at', '<cmd>CodeCompanionChat Toggle<cr>', mode = { 'n', 'v' }, desc = 'Toggle CodeCompanion Chat' },
    { '<leader>ac', '<cmd>CodeCompanionChat<cr>', mode = { 'n', 'v' }, desc = 'Open CodeCompanion Chat' },
    { 'ga', '<cmd>CodeCompanionChat Add<cr>', mode = 'v', desc = 'Add selection to CodeCompanion' }, -- Note: Overrides built-in 'ga' (print ASCII)
  },
}


-- Test comment added by CodeCompanion to verify diff tool
-- You can remove this line after testing

-- Second test comment to verify confirmation mode
-- This should require confirmation before being applied
