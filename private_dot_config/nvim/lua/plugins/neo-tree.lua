local util = require("config.util")

-- neo-tree bug: git.status returns early from its cache when `git status` output is
-- unchanged and drops the diff vs git_base, so a reopened tree came back empty
local function patch_git_status()
  local git = require("neo-tree.git")
  if git.base_patched then
    return
  end
  git.base_patched = true
  local status = git.status
  git.status = function(path, base_lookup, skip_bubbling, ...)
    local st, root, over_base = status(path, base_lookup, skip_bubbling, ...)
    local base = root and base_lookup and base_lookup[root]
    if st and base and not over_base then
      over_base = require("neo-tree.git.diff").diff_name_status(root, base, skip_bubbling)
    end
    return st, root, over_base
  end
end

return {
  "nvim-neo-tree/neo-tree.nvim",
  keys = {
    {
      "<leader>gM",
      function()
        local base = util.default_branch()
        if base then
          patch_git_status()
          require("neo-tree.command").execute({
            source = "git_status",
            git_base = base,
            toggle = true,
            position = util.centered() and "float" or nil,
          })
        end
      end,
      desc = "Changed files vs main/master",
    },
    {
      "<leader>gv",
      function()
        require("config.reviewed").toggle(vim.fn.expand("%:p"))
      end,
      desc = "Toggle file reviewed",
    },
  },
  opts = {
    git_status = {
      -- v marks a file reviewed (✓ in front); see config/reviewed.lua
      commands = {
        toggle_reviewed = function(state)
          local node = state.tree:get_node()
          if node.type == "file" then
            require("config.reviewed").toggle(node.path)
            require("neo-tree.ui.renderer").focus_node(state, node:get_id())
          end
        end,
      },
      window = { mappings = { ["v"] = "toggle_reviewed" } },
      components = {
        reviewed = function(_, node)
          local done = node.type == "file" and require("config.reviewed").is_reviewed(node.path)
          return { text = done and "✓ " or "  ", highlight = "NeoTreeGitAdded" }
        end,
      },
      renderers = {
        file = {
          { "indent" },
          { "reviewed" },
          { "icon" },
          {
            "container",
            content = {
              { "name", zindex = 10 },
              { "modified", zindex = 20, align = "right" },
              { "diagnostics", zindex = 20, align = "right" },
              { "git_status", zindex = 10, align = "right" },
            },
          },
        },
      },
    },
    filesystem = {
      bind_to_cwd = true,
      cwd_target = {
        sidebar = "tab",
        current = "window",
      },
    },
  },
}
