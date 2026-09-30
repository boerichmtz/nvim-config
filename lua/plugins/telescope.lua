-- Buscador: archivos (Ctrl+P), texto en el proyecto y paleta de comandos
-- La búsqueda de texto requiere ripgrep instalado en el sistema
return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  keys = {
    { "<C-p>", "<cmd>Telescope find_files<cr>", desc = "Buscar archivo" },
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Buscar archivo" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Buscar texto en el proyecto" },
    { "<C-S-f>", "<cmd>Telescope live_grep<cr>", desc = "Buscar texto en el proyecto" },
    { "<leader>fw", "<cmd>Telescope grep_string<cr>", desc = "Buscar palabra bajo el cursor" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Pestañas abiertas" },
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Archivos recientes" },
    { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Símbolos del archivo" },
    { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Problemas" },
    { "<C-S-p>", "<cmd>Telescope commands<cr>", desc = "Paleta de comandos" },
    { "<leader>p", "<cmd>Telescope commands<cr>", desc = "Paleta de comandos" },
  },
  config = function()
    local telescope = require("telescope")
    telescope.setup({
      defaults = {
        path_display = { "filename_first" },
        prompt_prefix = "  ",
        sorting_strategy = "ascending",
        layout_config = { prompt_position = "top" },
        file_ignore_patterns = { "%.git/", "build/", "__pycache__/", "%.venv/" },
      },
      pickers = {
        find_files = { hidden = true },
      },
    })
    pcall(telescope.load_extension, "fzf")
  end,
}
