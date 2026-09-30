-- Tema VS Code (Dark+)
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
    vim.cmd.colorscheme("vscode")
  end,
}
