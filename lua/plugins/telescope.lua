-- Finder: files (Ctrl+P), text across the project and command palette
-- Text search requires ripgrep installed on the system
return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  keys = {
    { "<C-p>", "<cmd>Telescope find_files<cr>", desc = "Find file" },
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find file" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Search text in project" },
    { "<C-S-f>", "<cmd>Telescope live_grep<cr>", desc = "Search text in project" },
    { "<leader>fw", "<cmd>Telescope grep_string<cr>", desc = "Search word under cursor" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Open tabs" },
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
    { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "File symbols" },
    { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Problems" },
    { "<C-S-p>", "<cmd>Telescope commands<cr>", desc = "Command palette" },
    { "<leader>p", "<cmd>Telescope commands<cr>", desc = "Command palette" },
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
