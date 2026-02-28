vim.keymap.set('n', '<space>l', function()
  local trim_spaces = true
  require("toggleterm").send_lines_to_terminal(
    "single_line",
    trim_spaces,
    { args = vim.v.count }
  )
end)

vim.keymap.set('v', '<space>l', function()
  local trim_spaces = true
  require('toggleterm').send_lines_to_terminal(
    'visual_selection',
    trim_spaces,
    { args = vim.v.count }
  )
end)

return {
  'akinsho/toggleterm.nvim',
  version = '*',
  config = true,
  event = 'VeryLazy',
  opts = {
    size = function(term)
      if term.direction == 'vertical' then
        return vim.o.columns * 0.5
      else
        return 20
      end
    end,
    open_mapping = [[<c-\>]],
  },
  keys = {
    {
      '<M-i>',
      '<cmd>ToggleTerm direction=float<cr>',
      desc = 'Toggle floating terminal',
    },
    {
      '<M-h>',
      '<cmd>ToggleTerm direction=horizontal<cr>',
      desc = 'Toggle horizontal terminal',
    },
    {
      '<M-v>',
      '<cmd>ToggleTerm direction=vertical<cr>',
      desc = 'Toggle vertical terminal',
    },
  },
}
