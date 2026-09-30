-- ~/.config/nvim/init.lua
-- Neovim estilo VS Code · requiere Neovim 0.11 o más reciente

-- Líder: debe definirse ANTES de cargar lazy.nvim
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.keymaps")

-- Bootstrap de lazy.nvim (se instala solo si no existe)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Error al clonar lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
    }, true, {})
    return
  end
end
vim.opt.rtp:prepend(lazypath)

-- Carga todos los archivos de lua/plugins/
require("lazy").setup({
  spec = { { import = "plugins" } },
  install = { colorscheme = { "vscode" } },
  checker = { enabled = false },
  change_detection = { notify = false },
})
