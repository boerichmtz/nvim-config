-- Sessions: reopen the files you had open last time in this folder (like VS Code)
-- and close tabs without closing the window layout
return {
  {
    "folke/persistence.nvim",
    lazy = false,
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore session for this folder" },
      { "<leader>ql", function() require("persistence").select() end, desc = "Pick a session" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "Don't save this session" },
    },
    config = function()
      -- Don't store the explorer or terminals in the session; they are reopened fresh
      vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp" }
      require("persistence").setup({ need = 1 })

      local group = vim.api.nvim_create_augroup("session_restore", { clear = true })
      vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "PersistenceSavePre",
        callback = function()
          pcall(vim.cmd, "Neotree close")
          -- Drop folder buffers (from "nvim .") so they don't come back as tabs
          for _, b in ipairs(vim.api.nvim_list_bufs()) do
            if vim.fn.isdirectory(vim.api.nvim_buf_get_name(b)) == 1 then
              pcall(vim.api.nvim_buf_delete, b, { force = true })
            end
          end
        end,
      })

      -- Auto-restore when nvim starts with no files or with a folder ("nvim" or "nvim .")
      vim.api.nvim_create_autocmd("VimEnter", {
        group = group,
        nested = true,
        callback = function()
          local argc = vim.fn.argc()
          if argc > 1 or (argc == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 0) then
            return
          end
          require("persistence").load()
          vim.schedule(function()
            pcall(vim.cmd, "Neotree show")
            -- Put the cursor in the editor, not in the explorer
            for _, w in ipairs(vim.api.nvim_list_wins()) do
              if vim.bo[vim.api.nvim_win_get_buf(w)].buftype == "" then
                vim.api.nvim_set_current_win(w)
                break
              end
            end
          end)
        end,
      })
    end,
  },

  -- Close a buffer but keep the window, so closing the last tab doesn't quit nvim
  {
    "echasnovski/mini.bufremove",
    lazy = true,
    init = function()
      local close = function(buf) require("mini.bufremove").delete(buf or 0, false) end
      vim.keymap.set("n", "<leader>x", function() close() end, { desc = "Close tab" })
      vim.api.nvim_create_user_command("CloseTab", function() close() end, { desc = "Close current tab" })
      _G.CloseBuffer = close
    end,
  },
}
