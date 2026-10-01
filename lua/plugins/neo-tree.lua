-- Sidebar file explorer (VS Code style)
return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  lazy = false, -- load at startup so "nvim ." opens the explorer
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
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
          local needed = depth * 2 + 4 + vim.api.nvim_strwidth(node.name or "")
          -- Room for the detail columns that are visible at this width
          if win >= 64 then needed = needed + 12 end  -- size
          if win >= 88 then needed = needed + 22 end  -- last modified
          if win >= 110 then needed = needed + 12 end -- type
          return math.max(win, needed)
        end,
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
        -- Home jumps back to the left edge
        ["<Home>"] = function() vim.cmd("normal! 0") end,
        -- T opens a NEW terminal in the selected folder
        ["T"] = function(state)
          local node = state.tree:get_node()
          local dir = vim.fn.getcwd()
          if node then
            dir = node.type == "directory" and node.path or vim.fn.fnamemodify(node.path, ":h")
          end
          vim.cmd("wincmd l")
          require("toggleterm.terminal").Terminal:new({ dir = dir }):toggle()
        end,
      },
    },
    filesystem = {
      follow_current_file = { enabled = true },
      use_libuv_file_watcher = true, -- refreshes when files are created/deleted
      hijack_netrw_behavior = "open_default",
      filtered_items = {
        hide_dotfiles = false,
        hide_gitignored = false,
      },
    },
  },
}
