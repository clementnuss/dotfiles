return {
  {
    "lewis6991/gitsigns.nvim",
    keys = {
      {
        "<leader>gm",
        function()
          require("gitsigns").change_base("main", true)
        end,
        desc = "Diff against main",
      },
      {
        "<leader>gr",
        function()
          require("gitsigns").reset_base(true)
        end,
        desc = "Reset diff base",
      },
    },
  },
}
