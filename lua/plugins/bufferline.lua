-- Pestañas superiores para buffers abiertos
return {
  "akinsho/bufferline.nvim",
  version = "*",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    -- Navegar entre pestañas con Alt + Izquierda / Derecha
    { "<A-Left>",  "<cmd>BufferLineCyclePrev<cr>", desc = "Buffer anterior" },
    { "<A-Right>", "<cmd>BufferLineCycleNext<cr>", desc = "Buffer siguiente" },
  },
  opts = {
    options = {
      diagnostics = "nvim_lsp",
      separator_style = "slant",
      offsets = {
        {
          filetype = "neo-tree",
          text = "Explorador",
          highlight = "Directory",
          text_align = "left",
        },
      },
    },
  },
}
