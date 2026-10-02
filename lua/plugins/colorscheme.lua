-- VS Code theme (Dark+)
return {
  "Mofiqul/vscode.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("vscode").setup({
      style = "dark",
      transparent = false,
      italic_comments = true,
      disable_nvim_tree_bg = true,
    })
    -- Explorer: make the selected row easy to see (VS Code's list selection blue;
    -- the theme's default is almost the same as the background)
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        vim.api.nvim_set_hl(0, "NeoTreeCursorLine", { bg = "#04395e", bold = true })
      end,
    })
    vim.cmd.colorscheme("vscode")
  end,
}
