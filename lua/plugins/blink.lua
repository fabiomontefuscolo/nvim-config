return {
  'saghen/blink.cmp',
  event = 'VimEnter',
  version = '1.*',
  dependencies = {
    'Kaiser-Yang/blink-cmp-avante',
    'giuxtaposition/blink-cmp-copilot',
    'folke/lazydev.nvim',
    {
      'L3MON4D3/LuaSnip',
      version = '2.*',
    },
  },
  opts = {
    keymap = {
      preset = 'default',
    },

    appearance = {
      nerd_font_variant = 'mono',
    },

    completion = {
      documentation = { auto_show = false, auto_show_delay_ms = 500 },
    },

    sources = {
      default = { 'lsp', 'path', 'copilot', 'snippets', 'buffer', 'lazydev' },
      providers = {
        lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
        copilot = {
          name = 'copilot',
          module = 'blink-cmp-copilot',
          score_offset = 100,
          async = true,
        },
      },
    },

    snippets = { preset = 'luasnip' },

    fuzzy = { implementation = 'lua' },

    signature = { enabled = true },
  },
}
