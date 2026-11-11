local review_base = require("config.util").review_base

return {
  {
    "lewis6991/gitsigns.nvim",
    keys = {
      {
        "<leader>gm",
        function()
          local base, branch = review_base()
          if not base then
            return
          end
          -- callback: report a failure (e.g. a buffer from another repo) instead of a stack trace
          require("gitsigns").change_base(base, true, function(err)
            if err then
              vim.notify("diff against " .. branch .. ": " .. err, vim.log.levels.WARN)
            end
          end)
        end,
        desc = "Diff against main/master",
      },
      {
        "<leader>gr",
        function()
          require("gitsigns").reset_base(true)
        end,
        desc = "Reset diff base",
      },
      {
        "<leader>go",
        function()
          local gs = require("gitsigns")
          -- one state for all three, so they can't drift out of sync
          local on = not require("gitsigns.config").config.word_diff
          gs.toggle_word_diff(on)
          gs.toggle_linehl(on)
          gs.toggle_deleted(on) ---@diagnostic disable-line: deprecated -- whole-buffer; preview_hunk_inline is per-hunk only
          gs.refresh()
        end,
        desc = "Toggle git diff overlay",
      },
      {
        "<leader>gO",
        function()
          require("gitsigns").preview_hunk_inline()
        end,
        desc = "Preview hunk inline",
      },
    },
  },
}
