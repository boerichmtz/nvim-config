-- Autocompletado con menú emergente (IntelliSense)
return {
  "saghen/blink.cmp",
  version = "1.*", -- usa el binario precompilado, no requiere Rust
  dependencies = { "rafamadriz/friendly-snippets" },
  event = { "InsertEnter", "CmdlineEnter" },
  opts = {
    keymap = {
      -- Tab acepta la sugerencia, como en VS Code
      preset = "super-tab",
      ["<CR>"] = { "accept", "fallback" },
      ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
    },
    appearance = { nerd_font_variant = "mono" },
    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 300 },
      menu = { border = "rounded" },
    },
    signature = { enabled = true },
    sources = { default = { "lsp", "path", "snippets", "buffer" } },
    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
}
