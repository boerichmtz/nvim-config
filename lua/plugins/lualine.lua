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
      -- Leave the terminal panel's tab bar alone (see config/terminal.lua)
      disabled_filetypes = { winbar = { "termpanel" } },
    },
  },
}
