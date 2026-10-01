-- Terminal panel with tabs (like VS Code's terminal panel)
-- One panel at the bottom; each terminal is a tab in the panel's top bar.
local M = { terms = {}, active = nil, win = nil, height = 15 }

local function valid_win() return M.win and vim.api.nvim_win_is_valid(M.win) end

local function index_of(buf)
  for i, t in ipairs(M.terms) do
    if t.buf == buf then return i end
  end
end

-- Tab bar drawn in the panel's winbar; tabs and "+" are clickable
function M.bar()
  local parts = {}
  for i, t in ipairs(M.terms) do
    local hl = (i == M.active) and "%#TabLineSel#" or "%#TabLine#"
    table.insert(parts, ("%s%%%d@v:lua.TermTabsClick@ %d: %s %%X"):format(hl, i, i, t.name))
  end
  table.insert(parts, "%#TabLine#%0@v:lua.TermTabsNew@ + %X%#TabLineFill#")
  return table.concat(parts, " ")
end

_G.TermTabsBar = function() return M.bar() end
_G.TermTabsClick = function(i) M.show(i) end
_G.TermTabsNew = function() M.new() end

local function refresh()
  if valid_win() then vim.cmd("redrawstatus!") end
end

local function open_panel()
  if valid_win() then
    vim.api.nvim_set_current_win(M.win)
    return
  end
  vim.cmd("botright " .. M.height .. "split")
  M.win = vim.api.nvim_get_current_win()
  local wo = vim.wo[M.win]
  wo.winfixheight = true
  wo.number = false
  wo.relativenumber = false
  wo.signcolumn = "no"
  wo.winbar = "%!v:lua.TermTabsBar()"
end

-- Show terminal i in the panel (creates one if it doesn't exist yet)
function M.show(i)
  local t = M.terms[i]
  if not t then return M.new() end
  open_panel()
  vim.api.nvim_win_set_buf(M.win, t.buf)
  M.active = i
  refresh()
  vim.cmd("startinsert")
end

-- New terminal tab, optionally in a given folder and with a name
function M.new(dir, name)
  dir = dir or vim.fn.getcwd()
  open_panel()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(M.win, buf)
  vim.fn.jobstart(vim.o.shell, {
    term = true,
    cwd = dir,
    on_exit = function() vim.schedule(function() M.remove(buf) end) end,
  })
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].buflisted = false
  table.insert(M.terms, { buf = buf, name = name or vim.fn.fnamemodify(dir, ":t") })
  M.active = #M.terms
  refresh()
  vim.cmd("startinsert")
end

-- Called when a shell exits or a tab is closed
function M.remove(buf)
  local i = index_of(buf)
  if not i then return end
  table.remove(M.terms, i)
  if #M.terms == 0 then
    M.active = nil
    if valid_win() then pcall(vim.api.nvim_win_close, M.win, true) end
  else
    local next_i = math.min(i, #M.terms)
    if valid_win() and vim.api.nvim_win_get_buf(M.win) == buf then
      vim.api.nvim_win_set_buf(M.win, M.terms[next_i].buf)
      M.active = next_i
    elseif M.active and M.active > i then
      M.active = M.active - 1
    end
  end
  if vim.api.nvim_buf_is_valid(buf) then pcall(vim.api.nvim_buf_delete, buf, { force = true }) end
  refresh()
end

function M.close_current()
  if M.active and M.terms[M.active] then M.remove(M.terms[M.active].buf) end
end

-- Ctrl+`: hide the panel if it's showing, otherwise show the last terminal
function M.toggle()
  if valid_win() then
    vim.api.nvim_win_close(M.win, true)
    M.win = nil
  else
    M.show(M.active or 1)
  end
end

function M.rename(name)
  if M.active and M.terms[M.active] and name ~= "" then
    M.terms[M.active].name = name
    refresh()
  end
end

-- Keep the active tab in sync when moving into the panel
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function(ev)
    local i = index_of(ev.buf)
    if i then M.active = i; refresh() end
  end,
})

-- Don't store the terminal panel in saved sessions
vim.api.nvim_create_autocmd("User", {
  pattern = "PersistenceSavePre",
  callback = function()
    if valid_win() then pcall(vim.api.nvim_win_close, M.win, true); M.win = nil end
  end,
})

-- Shortcuts
local map = vim.keymap.set
for _, key in ipairs({ "<C-`>", "<C-\\>" }) do
  map({ "n", "i", "t" }, key, M.toggle, { desc = "Toggle terminal panel" })
end
for i = 1, 9 do
  map({ "n", "t" }, "<A-" .. i .. ">", function() M.show(i) end, { desc = "Terminal tab " .. i })
end
map({ "n", "t" }, "<A-n>", function() M.new() end, { desc = "New terminal tab" })
map("n", "<leader>tn", function() M.new() end, { desc = "New terminal tab" })
map("n", "<leader>tx", M.close_current, { desc = "Close terminal tab" })
map("n", "<leader>tr", function()
  vim.ui.input({ prompt = "Terminal name: " }, function(name) if name then M.rename(name) end end)
end, { desc = "Rename terminal tab" })

vim.api.nvim_create_user_command("TermNew", function(o) M.new(nil, o.args ~= "" and o.args or nil) end,
  { nargs = "?", desc = "New terminal tab (optional name)" })
vim.api.nvim_create_user_command("TermClose", M.close_current, { desc = "Close terminal tab" })
vim.api.nvim_create_user_command("TermRename", function(o) M.rename(o.args) end,
  { nargs = 1, desc = "Rename terminal tab" })

return M
