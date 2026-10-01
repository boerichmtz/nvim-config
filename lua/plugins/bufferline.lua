-- Top tabs for open buffers
return {
  "akinsho/bufferline.nvim",
  version = "*",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    -- Switch tabs with Alt+Left / Alt+Right
    { "<A-Left>",  "<cmd>BufferLineCyclePrev<cr>", desc = "Previous buffer" },
    { "<A-Right>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
  },
  opts = {
    options = {
      -- Clicking the X (or middle click) closes only that tab
      close_command = function(n) _G.CloseBuffer(n) end,
      right_mouse_command = function() end,
      middle_mouse_command = function(n) _G.CloseBuffer(n) end,
      diagnostics = "nvim_lsp",
      separator_style = "slant",
      offsets = {
        {
          filetype = "neo-tree",
          text = "Explorer",
          highlight = "Directory",
          text_align = "left",
        },
      },
    },
  },
}
