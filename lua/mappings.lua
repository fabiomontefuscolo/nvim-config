-- https://github.com/NvChad/NvChad/blob/v2.5/lua/nvchad/mappings.lua
require "nvchad.mappings"

local map = vim.keymap.set
local unmap = vim.keymap.del
local gitsigns = require "gitsigns"

-- Copilot
map("i", "<C-a>", 'copilot#Accept("\\<CR>")', {
  desc = "Copilot Accept",
  expr = true,
  replace_keycodes = false,
})
vim.g.copilot_no_tab_map = true

-- Remove shortcuts I don't like
unmap("n", "<leader>h")
unmap("n", "<leader>v")
unmap("n", "<C-c>")

-- Gitsigns
map("n", "]c", function()
  if vim.wo.diff then
    vim.cmd.normal { "]c", bang = true }
  else
    gitsigns.nav_hunk "next"
  end
end, { desc = "Gitsigns Next hunk" })

map("n", "[c", function()
  if vim.wo.diff then
    vim.cmd.normal { "[c", bang = true }
  else
    gitsigns.nav_hunk "prev"
  end
end, { desc = "Gitsigns Previous hunk" })

map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "Gitsigns Stage hunk" })
map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "Gitsigns Reset hunk" })
map("v", "<leader>hs", function()
  gitsigns.stage_hunk { vim.fn.line ".", vim.fn.line "v" }
end, { desc = "Gitsigns Stage selected hunk" })
map("v", "<leader>hr", function()
  gitsigns.reset_hunk { vim.fn.line ".", vim.fn.line "v" }
end, { desc = "Gitsigns Reset selected hunk" })
map("n", "<leader>hS", gitsigns.stage_buffer, { desc = "Gitsigns Stage buffer" })
map("n", "<leader>hu", gitsigns.undo_stage_hunk, { desc = "Gitsigns Undo stage hunk" })
map("n", "<leader>hR", gitsigns.reset_buffer, { desc = "Gitsigns Reset buffer" })
map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "Gitsigns Preview hunk" })
map("n", "<leader>hb", function()
  gitsigns.blame_line { full = true }
end, { desc = "Gitsigns Blame line" })
map("n", "<leader>tb", gitsigns.toggle_current_line_blame, { desc = "Gitsigns Toggle blame line" })
map("n", "<leader>hd", gitsigns.diffthis, { desc = "Gitsigns Diff this" })
map("n", "<leader>hD", function()
  gitsigns.diffthis "~"
end, { desc = "Gitsigns Diff this (cached)" })
map("n", "<leader>td", gitsigns.toggle_deleted, { desc = "Gitsigns Toggle deleted" })

-- Text object
map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")

-- map("i", "jk", "<ESC>")
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
