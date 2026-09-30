-- Autocompletion popup (IntelliSense)
return {
  "saghen/blink.cmp",
  version = "1.*", -- uses the prebuilt binary, no Rust needed
  dependencies = { "rafamadriz/friendly-snippets" },
  event = { "InsertEnter", "CmdlineEnter" },
  opts = {
    keymap = {
      -- Tab accepts the suggestion, like VS Code
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
