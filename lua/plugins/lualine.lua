-- VS Code-style status line
return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    options = {
      theme = "vscode",
      globalstatus = true,
      component_separators = "",
      section_separators = "",
    },
  },
}
