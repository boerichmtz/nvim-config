-- Format document with Shift+Alt+F
-- C/C++: clang-format (uses your .clang-format if present) · Python: ruff
return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
      {
        "<A-F>", -- Shift+Alt+F
        function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
        mode = { "n", "v" },
        desc = "Format document",
      },
    },
    opts = {
      formatters_by_ft = {
        c = { "clang-format" },
        cpp = { "clang-format" },
        python = { "ruff_organize_imports", "ruff_format" },
        lua = { "stylua" },
      },
      -- To format on save (like "editor.formatOnSave"), uncomment:
      -- format_on_save = { timeout_ms = 1000, lsp_format = "fallback" },
    },
  },
  {
    -- Installs the formatters automatically through Mason
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    event = "VeryLazy",
    opts = {
      ensure_installed = { "clang-format", "ruff", "stylua" },
    },
  },
}
