-- Opciones generales del editor
local opt = vim.opt

opt.termguicolors = true      -- Colores completos (tema y pestañas)
opt.number = true
opt.relativenumber = false
opt.cursorline = true         -- Resalta la línea actual, como VS Code
opt.mouse = "a"
opt.clipboard = "unnamedplus" -- Usa el portapapeles del sistema
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.signcolumn = "yes"        -- Columna fija para errores y marcas de Git
opt.showmode = false          -- lualine ya muestra el modo
opt.wrap = false
opt.scrolloff = 8
opt.ignorecase = true         -- Búsqueda sin distinguir mayúsculas...
opt.smartcase = true          -- ...salvo que escribas alguna
opt.splitright = true
opt.splitbelow = true
opt.undofile = true           -- El historial de deshacer sobrevive al cerrar
opt.updatetime = 250
opt.timeoutlen = 400
opt.confirm = true            -- Pregunta antes de cerrar con cambios sin guardar
opt.laststatus = 3            -- Una sola barra de estado
opt.keymodel = "stopsel"      -- Flechas sin Shift cancelan la selección

-- Errores y advertencias en línea, como en VS Code
vim.diagnostic.config({
  virtual_text = { spacing = 2, prefix = "●" },
  severity_sort = true,
  underline = true,
  update_in_insert = false,
  float = { border = "rounded", source = true },
})
