return {
  {
    "smart-splits-nvim/smart-splits.nvim",
    version = "^3.0.0", -- v3 moved multiplexer support into separate backend plugins
    -- must not be lazy-loaded: the tmux backend has to mark the pane at startup,
    -- otherwise tmux swallows Alt/Ctrl+hjkl before neovim sees them
    lazy = false,
    dependencies = {
      -- sets the tmux pane option `@pane-is-vim` while neovim owns the pane;
      -- tilish's `@tilish-smartsplits` mode branches on it to forward Alt+hjkl
      { "smart-splits-nvim/backend-tmux", main = "smart-splits-backend-tmux" },
    },
    opts = {
      mux = { backend = "smart-splits-backend-tmux" },
    },
  },
}
