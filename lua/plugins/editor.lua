-- Editor extras: Git signs, terminal, auto-pairs, indent guides and shortcut help
return {
  -- Git marks in the gutter and blame for the current line
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      current_line_blame = true,
      current_line_blame_opts = { delay = 500 },
    },
    keys = {
      { "]h", "<cmd>Gitsigns next_hunk<cr>", desc = "Next change" },
      { "[h", "<cmd>Gitsigns prev_hunk<cr>", desc = "Previous change" },
      { "<leader>gp", "<cmd>Gitsigns preview_hunk<cr>", desc = "Preview change" },
      { "<leader>gr", "<cmd>Gitsigns reset_hunk<cr>", desc = "Discard change" },
    },
  },

  -- Integrated terminal: Ctrl+` (or Ctrl+\ if your terminal doesn't send Ctrl+`)
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

  -- Auto-close brackets, braces and quotes
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },

  -- Vertical indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = { indent = { char = "│" }, scope = { enabled = true } },
  },

  -- Shows available shortcuts after pressing the leader key (Space)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>f", group = "Find" },
        { "<leader>g", group = "Git" },
        { "<leader>c", group = "Code" },
      },
    },
  },
}
