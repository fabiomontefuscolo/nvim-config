local trim_spaces = true

vim.keymap.set('v', '<space>l', function()
  -- require("toggleterm").send_lines_to_terminal("single_line", trim_spaces, { args = vim.v.count })
  -- require("toggleterm").send_lines_to_terminal("visual_lines", trim_spaces, { args = vim.v.count })
  require('toggleterm').send_lines_to_terminal('visual_selection', trim_spaces, { args = vim.v.count })
end)

return {
  'akinsho/toggleterm.nvim',
  version = '*',
  config = true,
  event = 'VeryLazy',
  opts = {
    size = 10,
    open_mapping = [[<c-`>]],
  },
  keys = {
    { '<M-i>', '<cmd>ToggleTerm direction=float<cr>', desc = 'Toggle floating terminal' },
    { '<M-h>', '<cmd>ToggleTerm direction=horizontal<cr>', desc = 'Toggle horizontal terminal' },
    { '<M-v>', '<cmd>ToggleTerm direction=vertical size=60<cr>', desc = 'Toggle vertical terminal' },
  },
}
