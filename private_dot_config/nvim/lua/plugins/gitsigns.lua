-- the repo's default branch (main or master), local if it exists, else its remote ref
local function default_branch()
  local dir = vim.fn.expand("%:p:h")
  local function ok(ref)
    return vim.system({ "git", "-C", dir, "rev-parse", "--verify", "--quiet", ref }):wait().code == 0
  end
  local head = vim.system({ "git", "-C", dir, "rev-parse", "--abbrev-ref", "origin/HEAD" }):wait()
  local remote = head.code == 0 and vim.trim(head.stdout):match("^origin/(.+)") or nil
  for _, name in ipairs(remote and { remote } or { "main", "master" }) do
    if ok(name) then
      return name
    end
    if ok("origin/" .. name) then
      return "origin/" .. name
    end
  end
end

return {
  {
    "lewis6991/gitsigns.nvim",
    keys = {
      {
        "<leader>gm",
        function()
          local base = default_branch()
          if not base then
            return vim.notify("no main/master branch here", vim.log.levels.WARN)
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
