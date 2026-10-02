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
      -- One session per folder, whatever git branch you're on
      require("persistence").setup({ need = 1, branch = false })
      -- Folder nvim was opened in; the session is always saved under it, even if the
      -- explorer root was moved to a subfolder (which changes the working directory)
      local start_dir = nil

      local group = vim.api.nvim_create_augroup("session_restore", { clear = true })
      vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "PersistenceSavePre",
        callback = function()
          if start_dir and vim.fn.getcwd() ~= start_dir then
            vim.cmd.cd(vim.fn.fnameescape(start_dir))
          end
          pcall(vim.cmd, "Neotree close")
          vim.cmd("silent! %argdelete") -- don't store "nvim ." as a file to reopen
          -- Drop folder buffers (from "nvim .") so they don't come back as tabs
          for _, b in ipairs(vim.api.nvim_list_bufs()) do
            if vim.fn.isdirectory(vim.api.nvim_buf_get_name(b)) == 1 then
              pcall(vim.api.nvim_buf_delete, b, { force = true })
            end
          end
        end,
      })

      -- Remove folder tabs (e.g. "erick/") and leftover empty tabs after a restore
      local function tidy_buffers()
        local bufs = vim.fn.getbufinfo({ buflisted = 1 })
        local has_file = false
        for _, b in ipairs(bufs) do
          if b.name ~= "" and vim.fn.isdirectory(b.name) == 0 then has_file = true end
        end
        for _, b in ipairs(bufs) do
          local is_dir = b.name ~= "" and vim.fn.isdirectory(b.name) == 1
          local is_empty = b.name == "" and b.changed == 0 and has_file
          if is_dir or is_empty then
            require("mini.bufremove").delete(b.bufnr, true)
          end
        end
      end

      -- Like VS Code:
      --   nvim          -> reopen the last folder you worked in, with its tabs
      --   nvim <folder> -> open that folder, with its tabs
      --   nvim <files>  -> just those files; saved sessions are left untouched
      vim.api.nvim_create_autocmd("VimEnter", {
        group = group,
        nested = true,
        callback = function()
          local argc = vim.fn.argc()
          if argc > 1 or (argc == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 0) then
            require("persistence").stop()
            return
          end
          if argc == 1 then
            vim.cmd.cd(vim.fn.fnameescape(vim.fn.argv(0)))
            -- Replace the folder buffer with an empty one
            local dirbuf = vim.api.nvim_get_current_buf()
            vim.cmd("enew")
            pcall(vim.api.nvim_buf_delete, dirbuf, { force = true })
          end
          vim.cmd("silent! %argdelete")
          require("persistence").load({ last = argc == 0 })
          -- The session moves to its own folder; save back to that same folder on exit
          start_dir = vim.fn.getcwd()
          tidy_buffers()
          pcall(vim.cmd, "Neotree show dir=" .. vim.fn.fnameescape(start_dir))
          -- Leave the cursor in the editor, not in the explorer
          for _, w in ipairs(vim.api.nvim_list_wins()) do
            if vim.bo[vim.api.nvim_win_get_buf(w)].buftype == "" then
              vim.api.nvim_set_current_win(w)
              break
            end
          end
        end,
      })
    end,
  },

  -- Close a buffer but keep the window, so closing the last tab doesn't quit nvim
  {
    "echasnovski/mini.bufremove",
    lazy = true,
    init = function()
      local close = function(buf)
        if buf == nil or buf == 0 then buf = vim.api.nvim_get_current_buf() end
        local ft = vim.bo[buf].filetype
        -- In the terminal panel, close just that terminal tab and keep the panel
        if ft == "termpanel" then return require("config.terminal").remove(buf) end
        -- Never close the explorer this way
        if ft == "neo-tree" then return end
        require("mini.bufremove").delete(buf, false)
      end
      vim.keymap.set("n", "<leader>x", function() close() end, { desc = "Close tab" })
      vim.api.nvim_create_user_command("CloseTab", function() close() end, { desc = "Close current tab" })
      _G.CloseBuffer = close
    end,
  },
}
