return {
  'akinsho/toggleterm.nvim',
  version = '*',
  config = true,
  opts = {
    size = 10,
    open_mapping = [[<c-\>]],
  },
  keys = {
    { '<leader>tf', '<cmd>ToggleTerm direction=float<cr>', desc = 'Toggle floating terminal' },
    { '<leader>th', '<cmd>ToggleTerm direction=horizontal<cr>', desc = 'Toggle horizontal terminal' },
    { '<leader>tv', '<cmd>ToggleTerm direction=vertical size=60<cr>', desc = 'Toggle vertical terminal' },
  },
}
