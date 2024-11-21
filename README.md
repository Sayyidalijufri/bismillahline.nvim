# bismillahline.nvim

A beautiful and functional statusline for Neovim with Git integration, LSP diagnostics, and system information. Features elegant icons and a clean design inspired by Islamic aesthetics.

## ✨ Features

- 🎨 Beautiful and clean statusline design
- 🌿 Git integration showing branch and file status
- 📊 LSP diagnostics with error, warning, and info counts
- 💻 System information display (OS, Neovim version)
- 📱 Current mode indicator with distinctive icons
- 🔧 Plugin count from lazy.nvim
- 🕒 Date and time display
- 📜 Random inspirational quotes on startup

## ⚡️ Requirements

- Neovim >= 0.8.0
- [lazy.nvim](https://github.com/folke/lazy.nvim) package manager
- Git (optional, for Git integration)
- A Nerd Font for icons (recommended)

## 📦 Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    'Sayyidalijufri/bismillahline.nvim',
    dependencies = {
        'nvim-tree/nvim-web-devicons', -- optional, for file icons
    },
    config = function()
        require('bismillahline').init()
    end
}
```

## ⚙️ Configuration

The statusline comes with a beautiful default configuration. To initialize with default settings:

```lua
require('bismillahline').init()
```

## 🎨 Statusline Components

The statusline includes the following components:

- **Mode Indicator**: Shows current Vim mode with distinctive icons
  - Normal: ` NORMAL`
  - Insert: `󰫶 INSERT`
  - Visual: `󱂕 VISUAL`
  - Command: ` COMMAND`
  - And more...

- **Git Information**: 
  - Branch name: 🌿
  - Added files: `+`
  - Modified files: `~`
  - Deleted files: `-`

- **File Information**:
  - File name with icon
  - Read-only indicator: 🔒
  - Modified indicator: 🔄

- **LSP Diagnostics**:
  - Errors: 🚨
  - Warnings: ⚠️
  - Information: 🔍
  - Hints: 💡

- **System Information**:
  - Operating system with icon
  - Plugin count
  - Neovim version

- **Date and Time**:
  - Current date: 📅
  - Current time: 🕒

## 🎨 Highlights

The statusline uses the following highlight groups that you can customize:

```lua
BismillahLineNormal  -- Mode indicator
BismillahLineRound   -- Rounded separators
BismillahLineNC      -- Non-current window
BismillahLineGit     -- Git information
BismillahLineFile    -- File information
BismillahLineDiag    -- Diagnostics
BismillahLineInfo    -- System information
BismillahLineTime    -- Date and time
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.


## 🙏 Support

If you find this plugin useful, please consider starring the repository on GitHub.
