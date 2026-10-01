-- General VS Code-style shortcuts
-- (LSP shortcuts live in plugins/lsp.lua; search shortcuts in plugins/telescope.lua)
local map = vim.keymap.set

-- Ctrl+S saves from any mode
map({ "n", "i", "v" }, "<C-s>", "<cmd>write<cr><esc>", { desc = "Save" })

-- Ctrl+/ comments the line or selection
-- (many terminals send Ctrl+/ as Ctrl+_, so both are mapped)
for _, key in ipairs({ "<C-/>", "<C-_>" }) do
  map("n", key, "gcc", { remap = true, desc = "Comment line" })
  map("v", key, "gc", { remap = true, desc = "Comment selection" })
  map("i", key, "<esc>gcca", { remap = true, desc = "Comment line" })
end

-- Alt+Up/Down moves the line or selection
map("n", "<A-Up>", "<cmd>move .-2<cr>==", { desc = "Move line up" })
map("n", "<A-Down>", "<cmd>move .+1<cr>==", { desc = "Move line down" })
map("v", "<A-Up>", ":move '<-2<cr>gv=gv", { desc = "Move selection up" })
map("v", "<A-Down>", ":move '>+1<cr>gv=gv", { desc = "Move selection down" })

-- Tab / Shift+Tab indents the selection and keeps it selected
map("v", "<Tab>", ">gv", { desc = "Indent" })
map("v", "<S-Tab>", "<gv", { desc = "Outdent" })

-- Move between split panes with Ctrl+h/j/k/l
map("n", "<C-h>", "<C-w>h", { desc = "Pane left" })
map("n", "<C-j>", "<C-w>j", { desc = "Pane below" })
map("n", "<C-k>", "<C-w>k", { desc = "Pane above" })
map("n", "<C-l>", "<C-w>l", { desc = "Pane right" })

-- Esc clears the last search highlight
map("n", "<esc>", "<cmd>nohlsearch<cr>")

-- Shift+arrows select character by character / line by line (like VS Code)
-- Ctrl+Shift+Left/Right select word by word
local sel = {
  ["<S-Left>"] = "h", ["<S-Right>"] = "l", ["<S-Up>"] = "k", ["<S-Down>"] = "j",
  ["<C-S-Left>"] = "b", ["<C-S-Right>"] = "e",
}
for key, motion in pairs(sel) do
  map("n", key, "v" .. motion, { desc = "Select" })
  map("i", key, "<C-o>v" .. motion, { desc = "Select" })
  map("v", key, motion, { desc = "Extend selection" })
end

-- Alt+1/2/3 opens or switches to terminal 1, 2 or 3 (also from inside a terminal)
for i = 1, 3 do
  map({ "n", "t" }, "<A-" .. i .. ">", "<cmd>" .. i .. "ToggleTerm<cr>", { desc = "Terminal " .. i })
end
map("n", "<leader>tt", "<cmd>TermSelect<cr>", { desc = "Pick terminal" })

-- From a terminal: Ctrl+H/J/K/L switch panes without leaving terminal mode
map("t", "<C-h>", [[<Cmd>wincmd h<CR>]], { desc = "Pane left" })
map("t", "<C-j>", [[<Cmd>wincmd j<CR>]], { desc = "Pane below" })
map("t", "<C-k>", [[<Cmd>wincmd k<CR>]], { desc = "Pane above" })
map("t", "<C-l>", [[<Cmd>wincmd l<CR>]], { desc = "Pane right" })

-- Alt+E jumps to the file explorer from anywhere (also from a terminal)
map({ "n", "t" }, "<A-e>", "<cmd>Neotree focus<cr>", { desc = "Focus explorer" })

-- Shift+Alt+Up/Down duplicates the line or selection (like VS Code)
map("n", "<S-A-Down>", "<cmd>copy .<cr>", { desc = "Duplicate line down" })
map("n", "<S-A-Up>", "<cmd>copy .-1<cr>", { desc = "Duplicate line up" })
map("v", "<S-A-Down>", ":copy '><cr>gv", { desc = "Duplicate selection down" })
map("v", "<S-A-Up>", ":copy '<-1<cr>gv", { desc = "Duplicate selection up" })

-- Ctrl+C / Ctrl+X copy and cut the selection
map("v", "<C-c>", "y", { desc = "Copy" })
map("v", "<C-x>", "d", { desc = "Cut" })

-- Ctrl+F searches the current file
map("n", "<C-f>", "/", { desc = "Find in file" })
map("i", "<C-f>", "<Esc>/", { desc = "Find in file" })

-- Esc Esc leaves terminal mode (to copy text or scroll)
map("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- :UpdateConfig pulls the latest version of this configuration from GitHub
vim.api.nvim_create_user_command("UpdateConfig", function()
  local dir = vim.fn.stdpath("config")
  local out = vim.fn.system({ "git", "-C", dir, "pull", "--ff-only" })
  if vim.v.shell_error == 0 then
    vim.notify(out .. "\nRestart nvim to apply the changes.", vim.log.levels.INFO)
  else
    vim.notify("Update failed:\n" .. out, vim.log.levels.ERROR)
  end
end, { desc = "Pull the latest configuration" })
