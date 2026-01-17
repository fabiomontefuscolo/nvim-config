return {
  "saghen/blink.cmp",
  event = "VimEnter",
  version = "1.*",
  dependencies = {
    "giuxtaposition/blink-cmp-copilot",
    "folke/lazydev.nvim",
    {
      "L3MON4D3/LuaSnip",
      version = "2.*",
    },
  },
  opts = {
    keymap = {
      preset = "default",
      ["<CR>"] = { "accept", "fallback" }, -- Accept first/selected item with Enter
      ["<C-p>"] = { "select_prev", "fallback" }, -- Navigate up
      ["<C-n>"] = { "select_next", "fallback" }, -- Navigate down
    },

    appearance = {
      nerd_font_variant = "mono",
    },

    completion = {
      documentation = { auto_show = false, auto_show_delay_ms = 500 },
    },

    sources = {
      default = { "lsp", "path", "copilot", "snippets", "buffer", "lazydev" },
      providers = {
        lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
        copilot = {
          name = "copilot",
          module = "blink-cmp-copilot",
          score_offset = 100,
          async = true,
        },
      },
    },

    snippets = { preset = "luasnip" },

    fuzzy = { implementation = "lua" },

    signature = { enabled = true },
  },
}
