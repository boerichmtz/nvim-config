-- Sidebar file explorer (VS Code style)

-- Floating legend for the explorer's git/status icons (press L in the explorer)
local function show_legend()
  local cfg = require("neo-tree").config.default_component_configs
  local g = cfg.git_status.symbols
  local rows = {
    { g.modified, "Modified", "NeoTreeGitModified" },
    { g.added, "Added", "NeoTreeGitAdded" },
    { g.deleted, "Deleted", "NeoTreeGitDeleted" },
    { g.renamed, "Renamed", "NeoTreeGitRenamed" },
    { g.untracked, "Untracked (new, not in git)", "NeoTreeGitUntracked" },
    { g.ignored, "Ignored (.gitignore)", "NeoTreeGitIgnored" },
    { g.unstaged, "Has changes not staged yet", "NeoTreeGitUnstaged" },
    { g.staged, "Staged (git add)", "NeoTreeGitStaged" },
    { g.conflict, "Merge conflict", "NeoTreeGitConflict" },
    { cfg.modified.symbol, "Open file with unsaved changes", "NeoTreeModified" },
  }
  local lines = { " Explorer legend", "" }
  for _, r in ipairs(rows) do
    local icon = r[1] or ""
    icon = icon .. string.rep(" ", 4 - vim.api.nvim_strwidth(icon))
    table.insert(lines, "  " .. icon .. r[2])
  end
  vim.list_extend(lines, { "", " Name color also shows git status", " q / Esc to close" })
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  -- Color each icon and its label the same way the tree does
  local ns = vim.api.nvim_create_namespace("explorer_legend")
  for i, r in ipairs(rows) do
    vim.api.nvim_buf_set_extmark(buf, ns, i + 1, 2, { end_col = #lines[i + 2], hl_group = r[3] })
  end
  vim.api.nvim_buf_set_extmark(buf, ns, 0, 0, { end_col = #lines[1], hl_group = "Title" })
  vim.bo[buf].modifiable = false
  local width = 0
  for _, l in ipairs(lines) do width = math.max(width, vim.api.nvim_strwidth(l)) end
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor", style = "minimal", border = "rounded",
    width = width + 2, height = #lines,
    row = math.floor((vim.o.lines - #lines) / 2), col = math.floor((vim.o.columns - width) / 2),
  })
  for _, key in ipairs({ "q", "<Esc>", "L" }) do
    vim.keymap.set("n", key, function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
  end
end

-- Re-read git status for every repo shown in the tree. The explorer only refreshes the repo
-- at its root; when the root holds several repos (e.g. a `repo` workspace), the nested ones
-- kept showing old marks (a committed file still marked "?").
local function refresh_git_all()
  local ok, git = pcall(require, "neo-tree.git")
  if not ok then return end
  local opts = require("neo-tree").config.git_status_async_options or {}
  for root in pairs(git.worktrees) do
    git.status_async(root, nil, opts)
  end
end

return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  lazy = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  init = function()
    -- Coming back from the terminal (where you run git) or from another app: refresh git marks
    vim.api.nvim_create_autocmd("WinLeave", {
      callback = function()
        if vim.bo.buftype == "terminal" then vim.schedule(refresh_git_all) end
      end,
    })
    vim.api.nvim_create_autocmd("FocusGained", { callback = function() vim.schedule(refresh_git_all) end })
  end,
  keys = {
    -- Ctrl+B toggles the explorer (same as VS Code)
    { "<C-b>", "<cmd>Neotree toggle<cr>", desc = "Explorer" },
  },
  opts = {
    close_if_last_window = true,
    -- Never cut long names: rows that don't fit run past the edge (scroll with Left/Right),
    -- rows that fit keep the size/date columns aligned to the window edge
    default_component_configs = {
      container = {
        enable_character_fade = false,
        width = function(node, state)
          local win = vim.api.nvim_win_get_width(state.winid)
          local depth = node.get_depth and node:get_depth() or 1
          -- The container starts after the indent and the icon, so its full width is
          -- the window minus that prefix (this keeps the columns lined up at every depth)
          local prefix = (depth - 1) * 2 + 3
          local fit = win - prefix
          -- name + git/problem marks next to it
          local needed = vim.api.nvim_strwidth(node.name or "") + 6
          -- Room for the detail columns that are visible at this width
          if win >= 64 then needed = needed + 12 end  -- size
          if win >= 88 then needed = needed + 22 end  -- last modified
          if win >= 110 then needed = needed + 12 end -- type
          return math.max(fit, needed)
        end,
      },
    },
    -- Git status, problems and unsaved marks sit right after the name instead of at the
    -- far right edge; size/date columns stay on the right
    renderers = {
      directory = {
        { "indent" },
        { "icon" },
        { "current_filter" },
        {
          "container",
          content = {
            { "name", zindex = 10 },
            { "symlink_target", zindex = 10, highlight = "NeoTreeSymbolicLinkTarget" },
            { "clipboard", zindex = 10 },
            { "git_status", zindex = 10, align = "left", hide_when_expanded = true },
            { "diagnostics", errors_only = true, zindex = 10, align = "left", hide_when_expanded = true },
            { "file_size", zindex = 10, align = "right" },
            { "type", zindex = 10, align = "right" },
            { "last_modified", zindex = 10, align = "right" },
          },
        },
      },
      file = {
        { "indent" },
        { "icon" },
        {
          "container",
          content = {
            { "name", zindex = 10 },
            { "symlink_target", zindex = 10, highlight = "NeoTreeSymbolicLinkTarget" },
            { "clipboard", zindex = 10 },
            { "git_status", zindex = 10, align = "left" },
            { "diagnostics", zindex = 10, align = "left" },
            { "modified", zindex = 10, align = "left" },
            { "file_size", zindex = 10, align = "right" },
            { "type", zindex = 10, align = "right" },
            { "last_modified", zindex = 10, align = "right" },
          },
        },
      },
    },
    window = {
      width = 30,
      mappings = {
        -- Left/Right arrows scroll the tree sideways to read long paths
        ["<Right>"] = function() vim.cmd("normal! 5zl") end,
        ["<Left>"] = function() vim.cmd("normal! 5zh") end,
        -- Shift+mouse wheel also scrolls sideways
        ["<S-ScrollWheelDown>"] = function() vim.cmd("normal! 5zl") end,
        ["<S-ScrollWheelUp>"] = function() vim.cmd("normal! 5zh") end,
        ["<ScrollWheelRight>"] = function() vim.cmd("normal! 5zl") end,
        ["<ScrollWheelLeft>"] = function() vim.cmd("normal! 5zh") end,
        -- Space is the leader key (Space w + direction opens the file in a split)
        ["<space>"] = "none",
        -- L shows what the git/status icons mean
        ["L"] = show_legend,
        -- R refreshes files and the git marks of every repo in the tree
        ["R"] = function(state)
          require("neo-tree.sources.filesystem.commands").refresh(state)
          refresh_git_all()
        end,
        -- Home jumps back to the left edge
        ["<Home>"] = function() vim.cmd("normal! 0") end,
        -- T opens a new terminal tab in the selected folder
        ["T"] = function(state)
          local node = state.tree:get_node()
          local dir = vim.fn.getcwd()
          if node then
            dir = node.type == "directory" and node.path or vim.fn.fnamemodify(node.path, ":h")
          end
          require("config.terminal").new(dir)
        end,
      },
    },
    filesystem = {
      follow_current_file = { enabled = true },
      use_libuv_file_watcher = true, -- refreshes when files are created/deleted
      hijack_netrw_behavior = "disabled", -- "nvim ." is handled by plugins/session.lua
      filtered_items = {
        hide_dotfiles = false,
        hide_gitignored = false,
      },
    },
  },
}
