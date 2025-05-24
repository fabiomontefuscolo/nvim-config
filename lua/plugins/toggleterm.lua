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
  opts = {
    size = 10,
    open_mapping = [[<c-\>]],
  },
  keys = {
    { '<leader>tt', '<cmd>ToggleTerm<cr>', desc = 'Toggle terminal' },
    { '<leader>tf', '<cmd>ToggleTerm direction=float<cr>', desc = 'Toggle floating terminal' },
    { '<leader>th', '<cmd>ToggleTerm direction=horizontal<cr>', desc = 'Toggle horizontal terminal' },
    { '<leader>tv', '<cmd>ToggleTerm direction=vertical size=60<cr>', desc = 'Toggle vertical terminal' },
  },
}
