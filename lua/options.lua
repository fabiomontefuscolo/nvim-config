require "nvchad.options"

-- add yours here!

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!

local o = vim.opt
o.listchars:append {
  tab = "▸ ",
  eol = "¬",
}
