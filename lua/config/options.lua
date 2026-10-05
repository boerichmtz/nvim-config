-- General editor options
local opt = vim.opt

-- The explorer replaces netrw; folders passed to nvim are handled in plugins/session.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

opt.termguicolors = true      -- True colors (theme and tabs)
opt.number = true
opt.relativenumber = false
opt.cursorline = true         -- Highlight the current line, like VS Code
opt.mouse = "a"
opt.clipboard = "unnamedplus" -- Use the system clipboard
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.signcolumn = "yes"        -- Fixed column for errors and Git marks
opt.showmode = false          -- lualine already shows the mode
opt.wrap = false
opt.scrolloff = 8
opt.ignorecase = true         -- Case-insensitive search...
opt.smartcase = true          -- ...unless you type an uppercase letter
opt.splitright = true
opt.splitbelow = true
opt.undofile = true           -- Undo history survives closing the file
opt.updatetime = 250
opt.timeoutlen = 400
opt.confirm = true            -- Ask before closing with unsaved changes
opt.laststatus = 3            -- Single global status line
opt.keymodel = "stopsel"      -- Arrows without Shift cancel the selection
-- Symbols shown with :set list (off by default; :set nolist hides them again)
opt.listchars = { space = "␠", tab = "→ ", trail = "•", nbsp = "+" }

-- Inline errors and warnings, like VS Code
vim.diagnostic.config({
  virtual_text = { spacing = 2, prefix = "●" },
  severity_sort = true,
  underline = true,
  update_in_insert = false,
  float = { border = "rounded", source = true },
})
