-- Atajos generales estilo VS Code
-- (los de LSP están en plugins/lsp.lua; los de búsqueda en plugins/telescope.lua)
local map = vim.keymap.set

-- Ctrl+S guarda en cualquier modo
map({ "n", "i", "v" }, "<C-s>", "<cmd>write<cr><esc>", { desc = "Guardar" })

-- Ctrl+/ comenta la línea o la selección
-- (muchas terminales envían Ctrl+/ como Ctrl+_, por eso se mapean los dos)
for _, key in ipairs({ "<C-/>", "<C-_>" }) do
  map("n", key, "gcc", { remap = true, desc = "Comentar línea" })
  map("v", key, "gc", { remap = true, desc = "Comentar selección" })
  map("i", key, "<esc>gcca", { remap = true, desc = "Comentar línea" })
end

-- Alt+↑/↓ mueve la línea o la selección
map("n", "<A-Up>", "<cmd>move .-2<cr>==", { desc = "Mover línea arriba" })
map("n", "<A-Down>", "<cmd>move .+1<cr>==", { desc = "Mover línea abajo" })
map("v", "<A-Up>", ":move '<-2<cr>gv=gv", { desc = "Mover selección arriba" })
map("v", "<A-Down>", ":move '>+1<cr>gv=gv", { desc = "Mover selección abajo" })

-- Tab / Shift+Tab indenta la selección y la mantiene seleccionada
map("v", "<Tab>", ">gv", { desc = "Indentar" })
map("v", "<S-Tab>", "<gv", { desc = "Quitar indentación" })

-- Cerrar la pestaña (buffer) actual
map("n", "<leader>x", "<cmd>bdelete<cr>", { desc = "Cerrar pestaña" })

-- Moverse entre paneles divididos con Ctrl+h/j/k/l
map("n", "<C-h>", "<C-w>h", { desc = "Panel izquierdo" })
map("n", "<C-j>", "<C-w>j", { desc = "Panel inferior" })
map("n", "<C-k>", "<C-w>k", { desc = "Panel superior" })
map("n", "<C-l>", "<C-w>l", { desc = "Panel derecho" })

-- Esc quita el resaltado de la última búsqueda
map("n", "<esc>", "<cmd>nohlsearch<cr>")

-- Shift+flechas selecciona letra por letra / línea por línea (como VS Code)
-- Ctrl+Shift+←/→ selecciona palabra por palabra
local sel = {
  ["<S-Left>"] = "h", ["<S-Right>"] = "l", ["<S-Up>"] = "k", ["<S-Down>"] = "j",
  ["<C-S-Left>"] = "b", ["<C-S-Right>"] = "e",
}
for key, motion in pairs(sel) do
  map("n", key, "v" .. motion, { desc = "Seleccionar" })
  map("i", key, "<C-o>v" .. motion, { desc = "Seleccionar" })
  map("v", key, motion, { desc = "Extender selección" })
end

-- Alt+1/2/3 abre o cambia a la terminal 1, 2 o 3 (también desde dentro de una terminal)
for i = 1, 3 do
  map({ "n", "t" }, "<A-" .. i .. ">", "<cmd>" .. i .. "ToggleTerm<cr>", { desc = "Terminal " .. i })
end
map("n", "<leader>tt", "<cmd>TermSelect<cr>", { desc = "Elegir terminal" })

-- Desde la terminal: Ctrl+H/J/K/L cambia de panel sin salir primero
map("t", "<C-h>", [[<Cmd>wincmd h<CR>]], { desc = "Panel izquierdo" })
map("t", "<C-j>", [[<Cmd>wincmd j<CR>]], { desc = "Panel inferior" })
map("t", "<C-k>", [[<Cmd>wincmd k<CR>]], { desc = "Panel superior" })
map("t", "<C-l>", [[<Cmd>wincmd l<CR>]], { desc = "Panel derecho" })

-- Alt+E salta al explorador desde cualquier lugar (también desde la terminal)
map({ "n", "t" }, "<A-e>", "<cmd>Neotree focus<cr>", { desc = "Ir al explorador" })

-- Shift+Alt+↑/↓ duplica la línea o la selección (como VS Code)
map("n", "<S-A-Down>", "<cmd>copy .<cr>", { desc = "Duplicar línea abajo" })
map("n", "<S-A-Up>", "<cmd>copy .-1<cr>", { desc = "Duplicar línea arriba" })
map("v", "<S-A-Down>", ":copy '><cr>gv", { desc = "Duplicar selección abajo" })
map("v", "<S-A-Up>", ":copy '<-1<cr>gv", { desc = "Duplicar selección arriba" })

-- Ctrl+C / Ctrl+X copian y cortan la selección
map("v", "<C-c>", "y", { desc = "Copiar" })
map("v", "<C-x>", "d", { desc = "Cortar" })

-- Ctrl+F busca en el archivo actual
map("n", "<C-f>", "/", { desc = "Buscar en el archivo" })
map("i", "<C-f>", "<Esc>/", { desc = "Buscar en el archivo" })

-- Esc Esc sale del modo terminal (para copiar texto o hacer scroll)
map("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Salir del modo terminal" })

-- :ActualizarConfig descarga la última versión de esta configuración desde GitHub
vim.api.nvim_create_user_command("ActualizarConfig", function()
  local dir = vim.fn.stdpath("config")
  local out = vim.fn.system({ "git", "-C", dir, "pull", "--ff-only" })
  if vim.v.shell_error == 0 then
    vim.notify(out .. "\nReinicia nvim para aplicar los cambios.", vim.log.levels.INFO)
  else
    vim.notify("No se pudo actualizar:\n" .. out, vim.log.levels.ERROR)
  end
end, { desc = "Descargar la última versión de la configuración" })
