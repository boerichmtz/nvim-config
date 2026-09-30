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
    window = {
      width = 30,
      mappings = {
        -- Left/Right arrows scroll the tree sideways to read long paths
        ["<Right>"] = function() vim.cmd("normal! 5zl") end,
        ["<Left>"] = function() vim.cmd("normal! 5zh") end,
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
