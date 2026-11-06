return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      bind_to_cwd = true,
      cwd_target = {
        sidebar = "tab",
        current = "window",
      },
    },
  },
}
