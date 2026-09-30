-- Git: gráfica de commits (como Git Graph de VS Code) y vista de diferencias
return {
  -- Gráfica de ramas y commits
  {
    "rbong/vim-flog",
    cmd = { "Flog", "Flogsplit", "Floggit" },
    dependencies = { "tpope/vim-fugitive" },
    keys = {
      { "<leader>gl", "<cmd>Flog -all<cr>", desc = "Gráfica de Git (todas las ramas)" },
    },
  },

  -- Diferencias lado a lado e historial de archivos
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Ver cambios sin commit" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Historial del archivo" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Historial del proyecto" },
      { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Cerrar vista de cambios" },
    },
  },
}
