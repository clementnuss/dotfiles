return {
  {
    "lewis6991/gitsigns.nvim",
    keys = {
      {
        "<leader>gm",
        function()
          require("config.util").gitsigns_review_base()
        end,
        desc = "Diff against review base (:ReviewBase)",
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
