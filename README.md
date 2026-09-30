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
