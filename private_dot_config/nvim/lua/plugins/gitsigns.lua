local default_branch = require("config.util").default_branch

return {
  {
    "lewis6991/gitsigns.nvim",
    keys = {
      {
        "<leader>gm",
        function()
          local base = default_branch()
          if not base then
            return
          end
          -- callback: report a failure (e.g. a buffer from another repo) instead of a stack trace
          require("gitsigns").change_base(base, true, function(err)
            if err then
              vim.notify("diff against " .. base .. ": " .. err, vim.log.levels.WARN)
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
    },
  },
}
