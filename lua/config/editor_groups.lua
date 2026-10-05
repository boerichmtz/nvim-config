-- Editor groups (like VS Code): every editor split has its own row of tabs.
--   * Opening a file adds it as a tab to the window you are in
--   * Closing a tab removes it from that window only; closing the last tab closes the window
--   * The last editor window never closes; it just becomes empty
local M = {}

local state = {} -- [winid] = { bufnr, bufnr, ... } in tab order
local main_tab = nil -- the tabpage we manage (Diffview/Flog open their own tabpages)

local SKIP_FT = { ["neo-tree"] = true, termpanel = true, ["neo-tree-popup"] = true }

local function is_editor_win(win)
  if not vim.api.nvim_win_is_valid(win) then return false end
  if vim.api.nvim_win_get_config(win).relative ~= "" then return false end -- floating
  if main_tab and vim.api.nvim_win_get_tabpage(win) ~= main_tab then return false end
  local buf = vim.api.nvim_win_get_buf(win)
  return vim.bo[buf].buftype == "" and not SKIP_FT[vim.bo[buf].filetype]
end

local function is_tab_buf(buf)
  -- (not checking 'buflisted': the explorer lists a file only after showing it)
  return vim.api.nvim_buf_is_valid(buf)
    and vim.bo[buf].buftype == ""
    and vim.api.nvim_buf_get_name(buf) ~= ""
    and vim.fn.isdirectory(vim.api.nvim_buf_get_name(buf)) == 0
end

local function list(win)
  state[win] = state[win] or {}
  return state[win]
end

local function index_of(t, v)
  for i, x in ipairs(t) do
    if x == v then return i end
  end
end

local function editor_wins()
  local wins = {}
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(main_tab or 0)) do
    if is_editor_win(w) then table.insert(wins, w) end
  end
  return wins
end

local function in_any_list(buf, except_win)
  for w, l in pairs(state) do
    if w ~= except_win and vim.api.nvim_win_is_valid(w) and index_of(l, buf) then return true end
  end
  return false
end

------------------------------------------------------------------------------
-- Tab bar (drawn in each editor window's winbar; tabs, X and middle-click work)
------------------------------------------------------------------------------
function M.bar()
  local devicons_ok, devicons = pcall(require, "nvim-web-devicons")
  local win = vim.g.statusline_winid
  local l = state[win] or {}
  local cur = vim.api.nvim_win_get_buf(win)
  local active_win = win == vim.api.nvim_get_current_win()
  local parts = {}
  for _, buf in ipairs(l) do
    if vim.api.nvim_buf_is_valid(buf) then
      local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
      local selected = buf == cur
      local hl = selected and (active_win and "%#TabLineSel#" or "%#TabLine#") or "%#TabLineFill#"
      local icon = ""
      if devicons_ok then
        local ic = devicons.get_icon(name, nil, { default = true })
        if ic then icon = ic .. " " end
      end
      local mark = vim.bo[buf].modified and "●" or "×"
      table.insert(parts, ("%s%%%d@v:lua.EditorGroupsClick@ %s%s %%X%%%d@v:lua.EditorGroupsCloseClick@%s %%X")
        :format(hl, buf, icon, name:gsub("%%", "%%%%"), buf, mark))
    end
  end
  return table.concat(parts, "%#TabLineFill#│") .. "%#TabLineFill#"
end

local function clicked_win()
  local pos = vim.fn.getmousepos()
  return pos.winid ~= 0 and pos.winid or vim.api.nvim_get_current_win()
end

_G.EditorGroupsBar = M.bar
_G.EditorGroupsClick = function(buf, _, button)
  local win = clicked_win()
  if button == "m" then return M.close_tab(win, buf) end
  if vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_set_current_win(win)
    vim.api.nvim_win_set_buf(win, buf)
  end
end
_G.EditorGroupsCloseClick = function(buf) M.close_tab(clicked_win(), buf) end

-- Window-local options get reset when the buffer in a window changes, so re-apply
local function apply_bar(win)
  if not vim.api.nvim_win_is_valid(win) then return end
  if is_editor_win(win) then
    vim.api.nvim_set_option_value("winbar", "%!v:lua.EditorGroupsBar()", { win = win, scope = "local" })
  elseif vim.wo[win].winbar == "%!v:lua.EditorGroupsBar()" then
    vim.api.nvim_set_option_value("winbar", "", { win = win, scope = "local" })
  end
end

function M.refresh_all()
  for _, w in ipairs(vim.api.nvim_list_wins()) do apply_bar(w) end
  vim.cmd("redrawstatus!")
end

------------------------------------------------------------------------------
-- Tabs
------------------------------------------------------------------------------
local function add(win, buf)
  if not (is_editor_win(win) and is_tab_buf(buf)) then return end
  local l = list(win)
  if not index_of(l, buf) then
    -- New tabs go right after the current one, like VS Code
    local cur = index_of(l, vim.w[win].eg_last_buf)
    table.insert(l, cur and cur + 1 or #l + 1, buf)
  end
  vim.w[win].eg_last_buf = buf
end

-- Ask before throwing away unsaved changes. Returns false if the user cancels.
local function confirm_unsaved(buf)
  if not vim.bo[buf].modified then return true end
  local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
  local choice = vim.fn.confirm(("Save changes to %s?"):format(name), "&Save\n&Don't save\n&Cancel", 1)
  if choice == 1 then
    vim.api.nvim_buf_call(buf, function() vim.cmd("write") end)
    return true
  end
  return choice == 2
end

function M.close_tab(win, buf)
  win = (win == nil or win == 0) and vim.api.nvim_get_current_win() or win
  buf = (buf == nil or buf == 0) and vim.api.nvim_win_get_buf(win) or buf
  if not is_editor_win(win) then return end
  local l = list(win)
  local i = index_of(l, buf)
  local last_copy = not in_any_list(buf, win)
  if last_copy and not confirm_unsaved(buf) then return end
  if i then table.remove(l, i) end

  if vim.api.nvim_win_get_buf(win) == buf then
    if #l > 0 then
      vim.api.nvim_win_set_buf(win, l[math.min(i or 1, #l)])
    elseif #editor_wins() > 1 then
      state[win] = nil
      vim.api.nvim_win_close(win, true)
    else
      -- Last editor window: keep it, empty
      vim.api.nvim_win_call(win, function() vim.cmd("enew") end)
    end
  end
  if last_copy and vim.api.nvim_buf_is_valid(buf) and #vim.fn.win_findbuf(buf) == 0 then
    pcall(vim.api.nvim_buf_delete, buf, { force = true })
  end
  vim.cmd("redrawstatus!")
end

function M.cycle(step)
  local win = vim.api.nvim_get_current_win()
  if not is_editor_win(win) then return end
  local l = list(win)
  if #l < 2 then return end
  local i = index_of(l, vim.api.nvim_win_get_buf(win)) or 1
  vim.api.nvim_win_set_buf(win, l[(i - 1 + step) % #l + 1])
end

------------------------------------------------------------------------------
-- Splits
------------------------------------------------------------------------------
local SPLIT = {
  left = "leftabove vsplit", right = "rightbelow vsplit",
  up = "leftabove split", down = "rightbelow split",
}

-- Split `from_win` toward `dir` and open `buf` (or `path`) as the only tab of the new window
function M.split(dir, from_win, path)
  from_win = from_win or vim.api.nvim_get_current_win()
  local buf = path and vim.fn.bufadd(path) or vim.api.nvim_win_get_buf(from_win)
  vim.bo[buf].buflisted = true
  local new_win
  vim.api.nvim_win_call(from_win, function()
    vim.cmd(SPLIT[dir])
    new_win = vim.api.nvim_get_current_win()
  end)
  state[new_win] = {}
  vim.w[new_win].eg_last_buf = nil
  vim.api.nvim_set_current_win(new_win)
  vim.api.nvim_win_set_buf(new_win, buf)
  add(new_win, buf)
  apply_bar(new_win)
  return new_win
end

-- The editor window you were last in (used when splitting from the explorer)
local function last_editor_win()
  local prev = vim.fn.win_getid(vim.fn.winnr("#"))
  if is_editor_win(prev) then return prev end
  if M.last_win and is_editor_win(M.last_win) then return M.last_win end
  return editor_wins()[1]
end

-- From the explorer: open the selected file in a new split toward `dir`
function M.split_from_tree(dir)
  local ok, mgr = pcall(require, "neo-tree.sources.manager")
  if not ok then return end
  local st = mgr.get_state("filesystem")
  local node = st and st.tree and st.tree:get_node()
  if not node or node.type ~= "file" then
    vim.notify("Select a file in the explorer first", vim.log.levels.INFO)
    return
  end
  local target = last_editor_win()
  if not target then
    vim.cmd("wincmd l")
    vim.cmd.edit(vim.fn.fnameescape(node.path))
    return
  end
  M.split(dir, target, node.path)
end

------------------------------------------------------------------------------
-- Sessions: remember each window's tabs (stored in a global the session saves)
------------------------------------------------------------------------------
function M.save()
  local groups = {}
  for _, w in ipairs(editor_wins()) do
    local files = {}
    for _, b in ipairs(state[w] or {}) do
      if is_tab_buf(b) then table.insert(files, vim.api.nvim_buf_get_name(b)) end
    end
    table.insert(groups, files)
  end
  vim.g.EditorGroups = vim.json.encode(groups)
end

function M.restore()
  main_tab = vim.api.nvim_get_current_tabpage()
  local ok, groups = pcall(vim.json.decode, vim.g.EditorGroups or "[]")
  local wins = editor_wins()
  for i, w in ipairs(wins) do
    state[w] = {}
    local files = ok and groups[i] or {}
    for _, f in ipairs(files) do
      local b = vim.fn.bufnr(f)
      if b > 0 and is_tab_buf(b) then table.insert(state[w], b) end
    end
    local cur = vim.api.nvim_win_get_buf(w)
    if is_tab_buf(cur) and not index_of(state[w], cur) then table.insert(state[w], cur) end
    vim.w[w].eg_last_buf = cur
  end
  M.refresh_all()
end

------------------------------------------------------------------------------
-- Events
------------------------------------------------------------------------------
local group = vim.api.nvim_create_augroup("editor_groups", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
  group = group,
  callback = function() main_tab = main_tab or vim.api.nvim_get_current_tabpage() end,
})

vim.api.nvim_create_autocmd({ "BufWinEnter", "BufFilePost" }, {
  group = group,
  callback = function(ev)
    -- The explorer opens files from its own window, so look at every window showing
    -- this buffer instead of only the current one
    for _, win in ipairs(vim.fn.win_findbuf(ev.buf)) do
      add(win, ev.buf)
      apply_bar(win)
    end
  end,
})

vim.api.nvim_create_autocmd({ "WinEnter", "WinNew", "FileType" }, {
  group = group,
  callback = function()
    local win = vim.api.nvim_get_current_win()
    apply_bar(win)
    if is_editor_win(win) then M.last_win = win end
  end,
})

-- A new split (e.g. Ctrl+W v) starts with just the file it was split from
vim.api.nvim_create_autocmd("WinNew", {
  group = group,
  callback = function()
    local win = vim.api.nvim_get_current_win()
    if state[win] == nil then
      state[win] = {}
      add(win, vim.api.nvim_win_get_buf(win))
    end
  end,
})

-- Closing a window closes its tabs (files still open elsewhere stay open)
vim.api.nvim_create_autocmd("WinClosed", {
  group = group,
  callback = function(ev)
    local win = tonumber(ev.match)
    local l = state[win]
    state[win] = nil
    if not l then return end
    vim.schedule(function()
      for _, b in ipairs(l) do
        if vim.api.nvim_buf_is_valid(b) and not vim.bo[b].modified
          and not in_any_list(b) and #vim.fn.win_findbuf(b) == 0 then
          pcall(vim.api.nvim_buf_delete, b, {})
        end
      end
    end)
  end,
})

vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
  group = group,
  callback = function(ev)
    for _, l in pairs(state) do
      local i = index_of(l, ev.buf)
      if i then table.remove(l, i) end
    end
  end,
})

vim.api.nvim_create_autocmd({ "BufModifiedSet", "BufWritePost" }, {
  group = group,
  callback = function() vim.cmd("redrawstatus!") end,
})

vim.api.nvim_create_autocmd("User", {
  group = group,
  pattern = "PersistenceSavePre",
  callback = M.save,
})

-- The status line plugin clears window bars when it loads; put ours back
vim.api.nvim_create_autocmd("User", {
  group = group,
  pattern = "VeryLazy",
  callback = function() vim.defer_fn(M.refresh_all, 50) end,
})

------------------------------------------------------------------------------
-- Shortcuts
------------------------------------------------------------------------------
local map = vim.keymap.set
map("n", "<A-Left>", function() M.cycle(-1) end, { desc = "Previous tab" })
map("n", "<A-Right>", function() M.cycle(1) end, { desc = "Next tab" })
map("n", "<leader>\\", function() M.split("right") end, { desc = "Split right" })
map("n", "<leader>-", function() M.split("down") end, { desc = "Split down" })

-- Space w + arrow / h j k l: move to the window on that side
local MOVE = { h = "h", j = "j", k = "k", l = "l", ["<Left>"] = "h", ["<Down>"] = "j", ["<Up>"] = "k", ["<Right>"] = "l" }
for key, dir in pairs(MOVE) do
  map("n", "<leader>w" .. key, "<cmd>wincmd " .. dir .. "<cr>", { desc = "Go to window " .. dir })
end
map("n", "<leader>wc", "<cmd>close<cr>", { desc = "Close window" })

-- In the explorer, Ctrl+W / Space w + direction opens the selected file in a split
local SPLIT_KEYS = { h = "left", j = "down", k = "up", l = "right",
  ["<Left>"] = "left", ["<Down>"] = "down", ["<Up>"] = "up", ["<Right>"] = "right" }
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "neo-tree",
  callback = function(ev)
    for key, dir in pairs(SPLIT_KEYS) do
      for _, prefix in ipairs({ "<C-w>", "<leader>w" }) do
        map("n", prefix .. key, function() M.split_from_tree(dir) end,
          { buffer = ev.buf, desc = "Open in split " .. dir })
      end
    end
  end,
})

vim.api.nvim_create_user_command("SplitRight", function() M.split("right") end, {})
vim.api.nvim_create_user_command("SplitDown", function() M.split("down") end, {})

return M
