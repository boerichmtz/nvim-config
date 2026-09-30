-- Formatear documento con Shift+Alt+F
-- C/C++: clang-format (usa tu .clang-format si existe) · Python: ruff
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
        desc = "Formatear documento",
      },
    },
    opts = {
      formatters_by_ft = {
        c = { "clang-format" },
        cpp = { "clang-format" },
        python = { "ruff_organize_imports", "ruff_format" },
        lua = { "stylua" },
      },
      -- Para formatear al guardar (como "editor.formatOnSave"), quita el comentario:
      -- format_on_save = { timeout_ms = 1000, lsp_format = "fallback" },
    },
  },
  {
    -- Instala automáticamente los formateadores con Mason
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    event = "VeryLazy",
    opts = {
      ensure_installed = { "clang-format", "ruff", "stylua" },
    },
  },
}
