-- Barra de estado inferior estilo VS Code
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
