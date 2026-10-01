# VS Code-style Neovim

Neovim configuration with the look and shortcuts of VS Code, for C, C++ and Python.

## Install (WSL / Linux)

```
mv ~/.config/nvim ~/.config/nvim.bak-$(date +%Y%m%d)   # backup, if one exists
git clone https://github.com/boerichmtz/nvim-config ~/.config/nvim
nvim
```

Requires Neovim 0.11+, git, gcc, make, unzip, ripgrep and Node.js (for pyright).

## Update

Inside nvim: `:UpdateConfig`, then restart nvim.
Or from the shell: `git -C ~/.config/nvim pull`.

## Explorer icons

Git status appears right after the file name. The name's color shows the status too.
Press `L` inside the explorer to see this legend in nvim.

| Icon | Color | Meaning |
|------|-------|---------|
|  | yellow | Modified |
| ✚ | green | Added |
| ✖ | red | Deleted |
| 󰁕 | yellow | Renamed |
|  | orange | Untracked (new, not in git) |
|  | blue-gray | Ignored (.gitignore) |
| 󰄱 | orange | Has changes not staged yet |
|  | green | Staged (`git add`) |
|  | orange | Merge conflict |
| [+] | yellow | Open file with unsaved changes |

A modified file that isn't staged shows two icons: ` 󰄱`.
Icons need a Nerd Font in the terminal (e.g. JetBrainsMono Nerd Font Mono).
