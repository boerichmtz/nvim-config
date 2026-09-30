-- Explorador de archivos lateral (estilo VS Code)
return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  lazy = false, -- carga al inicio para que "nvim ." abra el explorador
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  keys = {
    -- Ctrl+b abre/cierra el explorador (igual que en VS Code)
    { "<C-b>", "<cmd>Neotree toggle<cr>", desc = "Explorador" },
  },
  opts = {
    close_if_last_window = true,
    window = {
      width = 30,
      mappings = {
        -- Flechas ← → desplazan el árbol a los lados para ver rutas largas
        ["<Right>"] = function() vim.cmd("normal! 5zl") end,
        ["<Left>"] = function() vim.cmd("normal! 5zh") end,
        -- T abre una terminal NUEVA en la carpeta seleccionada
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
      use_libuv_file_watcher = true, -- se actualiza solo al crear/borrar archivos
      hijack_netrw_behavior = "open_default",
      filtered_items = {
        hide_dotfiles = false,
        hide_gitignored = false,
      },
    },
  },
}
