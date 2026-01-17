vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = false

vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4

vim.o.number = true
vim.o.relativenumber = true
-- vim.o.mouse = 'a'
vim.o.showmode = false
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = false
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true

vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- Add command to allow :W as an alias for :write
vim.cmd 'command W write'
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('t', '<C-x>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
-- Smart buffer delete that preserves window layout
vim.keymap.set('n', '<leader>x', function()
  local current_buf = vim.api.nvim_get_current_buf()
  local buffers = vim.fn.getbufinfo({ buflisted = 1 })

  -- Filter out current buffer and get other listed buffers
  local other_buffers = {}
  for _, buf in ipairs(buffers) do
    if buf.bufnr ~= current_buf then
      table.insert(other_buffers, buf.bufnr)
    end
  end

  -- If there are other buffers, switch to the next one before deleting
  if #other_buffers > 0 then
    vim.cmd('buffer ' .. other_buffers[1])
  else
    -- If this is the last buffer, create a new empty buffer
    vim.cmd('enew')
  end

  -- Now delete the original buffer
  vim.cmd('bdelete! ' .. current_buf)
end, { desc = 'Close current buffer' })
vim.keymap.set('n', '<leader>rn', ':set rnu!<CR>', { desc = 'Toggle relative number' })

vim.keymap.set('n', 'gf', function()
  local window_list = vim.api.nvim_list_wins()
  local window_id = math.min(unpack(window_list))

  local file = vim.fn.expand '<cfile>'

  vim.api.nvim_set_current_win(window_id)
  vim.api.nvim_command('edit ' .. file)
end, { desc = 'Open file under cursor in a specific window' })

-- Copy relative file path=expand('%)
vim.keymap.set('n', '<f4>', function()
  local path = vim.fn.expand '%'
  vim.fn.setreg('+', path)
end, { desc = 'Copy relative file path to the clipboard' })

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end

local rtp = vim.opt.rtp
rtp:prepend(lazypath)

require('lazy').setup({
  'NMAC427/guess-indent.nvim', -- Detect tabstop and shiftwidth automatically

  require 'plugins.toggleterm',
  require 'plugins.gitsigns',
  require 'plugins.which-key',
  require 'plugins.telescope',
  require 'plugins.lazydev',
  require 'plugins.lspconfig',
  require 'plugins.conform',
  require 'plugins.blink',
  require 'plugins.tokyonight',
  require 'plugins.todo-comments',
  require 'plugins.mini',
  require 'plugins.bufferline',
  require 'plugins.nvim-treesitter',

  require 'plugins.debug',
  require 'plugins.neo-tree',
  require 'plugins.gitsigns',
  require 'plugins.gitlinker',

  require 'plugins.copilot',
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})
