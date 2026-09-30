-- Detalles del editor: Git, terminal, cierre de paréntesis, guías y ayuda de atajos
return {
  -- Marcas de Git en el margen y "blame" de la línea actual
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      current_line_blame = true,
      current_line_blame_opts = { delay = 500 },
    },
    keys = {
      { "]h", "<cmd>Gitsigns next_hunk<cr>", desc = "Siguiente cambio" },
      { "[h", "<cmd>Gitsigns prev_hunk<cr>", desc = "Cambio anterior" },
      { "<leader>gp", "<cmd>Gitsigns preview_hunk<cr>", desc = "Ver cambio" },
      { "<leader>gr", "<cmd>Gitsigns reset_hunk<cr>", desc = "Descartar cambio" },
    },
  },

  -- Terminal integrada: Ctrl+` (o Ctrl+\ si tu terminal no envía Ctrl+`)
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = "ToggleTerm",
    keys = { "<C-`>", "<C-\\>" },
    opts = {
      open_mapping = { "<C-`>", "<C-\\>" },
      direction = "horizontal",
      size = 15,
    },
  },

  -- Cierra paréntesis, llaves y comillas automáticamente
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },

  -- Guías verticales de indentación
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = { indent = { char = "│" }, scope = { enabled = true } },
  },

  -- Muestra los atajos disponibles al presionar la tecla líder (Espacio)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>f", group = "Buscar" },
        { "<leader>g", group = "Git" },
        { "<leader>c", group = "Código" },
      },
    },
  },
}
