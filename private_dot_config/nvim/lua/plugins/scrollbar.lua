return {
  "petertriho/nvim-scrollbar",
  -- v2 preview branch; remove this pin once v2 lands on main (2026-11-16)
  branch = "refactor/v2",
  dependencies = {
    "lewis6991/gitsigns.nvim",
  },
  opts = {
    providers = {
      gitsigns = true,
      search = true,
    },
  },
}
