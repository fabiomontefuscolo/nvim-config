# Kickstart.nvim (Personal Fork)

A personalized fork of [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) with custom configurations and additional plugins for enhanced development experience.

## Features

- Modern Neovim configuration with Lua
- Streamlined key mappings for efficient navigation and editing
- Integrated terminal with toggleterm
- Comprehensive LSP setup with intelligent code completion
- Git integration with gitsigns
- Fuzzy finding with Telescope
- File explorer with Neo-tree
- Debugging capabilities with DAP
- AI assistance with GitHub Copilot and Avante
- Code formatting with conform.nvim
- Syntax highlighting with Treesitter
- Beautiful UI with Tokyo Night theme

## Key Mappings

### General

- `Space` - Leader key
- `<Esc>` - Clear search highlighting
- `<C-h/j/k/l>` - Navigate between windows
- `<Tab>/<S-Tab>` - Cycle through buffers
- `<leader>x` - Close current buffer
- `<C-\>` - Toggle terminal
- `<C-x>` - Exit terminal mode

### File Navigation

- `\` - Open Neo-tree file explorer
- `<leader>sf` - Search files
- `<leader>sg` - Search by grep
- `<leader><leader>` - Find existing buffers

### LSP

- `grn` - Rename symbol
- `gra` - Code action
- `grr` - Find references
- `grd` - Go to definition
- `grt` - Go to type definition
- `grD` - Go to declaration

### Git

- `]c/[c` - Jump to next/previous git change
- `<leader>hs` - Stage hunk
- `<leader>hr` - Reset hunk
- `<leader>hb` - Blame line
- `<leader>hd` - Diff against index

### Debugging

- `<F5>` - Start/Continue debugging
- `<F1>` - Step into
- `<F2>` - Step over
- `<F3>` - Step out
- `<leader>b` - Toggle breakpoint
- `<F7>` - Toggle debug UI

### Terminal

- `<leader>tt` - Toggle terminal
- `<leader>tf` - Toggle floating terminal
- `<leader>th` - Toggle horizontal terminal
- `<leader>tv` - Toggle vertical terminal

## Installation

1. Backup your existing Neovim configuration:
```bash
mv ~/.config/nvim ~/.config/nvim.bak
```

2. Clone this repository:
```bash
git clone git@github.com:fabiomontefuscolo/nvim-config ~/.config/nvim
```

3. Start Neovim:
```bash
nvim
```

The configuration will automatically install Lazy.nvim and all required plugins.

## Requirements

- Neovim 0.9.0 or higher
- Git
- A C compiler (for some plugins)
- (Optional) A Nerd Font for icons

## Customization

This configuration is designed to be a starting point. Feel free to modify any part of it to suit your needs. The main configuration is organized into modular files in the `lua/plugins` directory.

## Acknowledgements

- Original [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) project
- All plugin authors for their amazing work

## License

Same as the original kickstart.nvim project.
