-- Code intelligence: errors, go to definition, rename, etc.
-- clangd (C/C++), pyright (Python) and lua_ls (for this config)
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
      -- Completion capabilities for every server
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      -- clangd: include insertion and detailed completions
      vim.lsp.config("clangd", {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
        },
      })

      -- lua_ls: treat "vim" as a global when editing this config
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
          },
        },
      })

      -- Install the servers and enable them automatically
      require("mason-lspconfig").setup({
        ensure_installed = { "clangd", "pyright", "lua_ls" },
        automatic_enable = true,
      })

      -- VS Code shortcuts, active only when a server is attached
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
          end
          local tb = require("telescope.builtin")
          map("n", "<F12>", tb.lsp_definitions, "Go to definition")
          map("n", "gd", tb.lsp_definitions, "Go to definition")
          map("n", "<S-F12>", tb.lsp_references, "Find references")
          map("n", "gr", tb.lsp_references, "Find references")
          map("n", "gi", tb.lsp_implementations, "Go to implementation")
          map("n", "<F2>", vim.lsp.buf.rename, "Rename symbol")
          map({ "n", "v" }, "<C-.>", vim.lsp.buf.code_action, "Quick fix")
          map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Quick fix")
          map("n", "K", vim.lsp.buf.hover, "Hover documentation")
          map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature help")
          map("n", "<F8>", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next problem")
          map("n", "<S-F8>", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Previous problem")
          map("n", "<leader>e", vim.diagnostic.open_float, "Show full diagnostic")

          -- Alt+O switches between header and source (like the C/C++ extension)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client.name == "clangd" then
            map("n", "<A-o>", "<cmd>LspClangdSwitchSourceHeader<cr>", "Switch header / source")
          end
        end,
      })
    end,
  },
}
