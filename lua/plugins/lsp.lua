-- Inteligencia de código: errores, ir a definición, renombrar, etc.
-- clangd (C/C++), pyright (Python) y lua_ls (esta misma configuración)
return {
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    opts = { ui = { border = "rounded" } },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    lazy = false,
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
      "saghen/blink.cmp",
    },
    config = function()
      -- Capacidades de autocompletado para todos los servidores
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      -- clangd: include ordenados y sugerencias completas
      vim.lsp.config("clangd", {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
        },
      })

      -- lua_ls: reconoce "vim" como global al editar esta configuración
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
          },
        },
      })

      -- Instala los servidores y los activa automáticamente
      require("mason-lspconfig").setup({
        ensure_installed = { "clangd", "pyright", "lua_ls" },
        automatic_enable = true,
      })

      -- Atajos de VS Code, activos solo cuando hay un servidor conectado
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
          end
          local tb = require("telescope.builtin")
          map("n", "<F12>", tb.lsp_definitions, "Ir a definición")
          map("n", "gd", tb.lsp_definitions, "Ir a definición")
          map("n", "<S-F12>", tb.lsp_references, "Ver referencias")
          map("n", "gr", tb.lsp_references, "Ver referencias")
          map("n", "gi", tb.lsp_implementations, "Ir a implementación")
          map("n", "<F2>", vim.lsp.buf.rename, "Renombrar símbolo")
          map({ "n", "v" }, "<C-.>", vim.lsp.buf.code_action, "Acciones rápidas")
          map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Acciones rápidas")
          map("n", "K", vim.lsp.buf.hover, "Documentación")
          map("i", "<C-k>", vim.lsp.buf.signature_help, "Parámetros de la función")
          map("n", "<F8>", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Siguiente error")
          map("n", "<S-F8>", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Error anterior")
          map("n", "<leader>e", vim.diagnostic.open_float, "Ver error completo")

          -- Alt+O cambia entre .h y .cpp (como la extensión de C/C++)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client.name == "clangd" then
            map("n", "<A-o>", "<cmd>LspClangdSwitchSourceHeader<cr>", "Cambiar .h / .cpp")
          end
        end,
      })
    end,
  },
}
