-- Accurate syntax highlighting (like VS Code)
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "c", "cpp", "python", "cmake", "make",
        "lua", "vim", "vimdoc", "bash", "json", "yaml", "markdown",
      },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}
