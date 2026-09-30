# Neovim estilo VS Code

Configuración de Neovim con apariencia y atajos de VS Code, para C, C++ y Python.

## Instalar (WSL / Linux)

```
mv ~/.config/nvim ~/.config/nvim.bak-$(date +%Y%m%d)   # respaldo, si ya existe
git clone https://github.com/boerichmtz/nvim-config ~/.config/nvim
nvim
```

Requiere Neovim 0.11+, git, gcc, make, unzip, ripgrep y Node.js (para pyright).

## Actualizar

Dentro de nvim: `:ActualizarConfig` y reinicia nvim.
O desde la terminal: `git -C ~/.config/nvim pull`.
