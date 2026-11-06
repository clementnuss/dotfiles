return {
  {
    "smart-splits-nvim/smart-splits.nvim",
    version = "^3.0.0",
    -- not lazy: the tmux backend must set @pane-is-vim at startup for tilish to forward Alt+hjkl
    lazy = false,
    dependencies = {
      { "smart-splits-nvim/backend-tmux", main = "smart-splits-backend-tmux" },
    },
    opts = {
      mux = { backend = "smart-splits-backend-tmux" },
    },
  },
}
