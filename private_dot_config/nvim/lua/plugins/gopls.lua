-- opts merge with LazyVim's lang.go extra
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      gopls = {
        settings = {
          gopls = {
            -- golangci-lint (nvim-lint) already runs staticcheck with the repo's
            -- config; in gopls it gates first diagnostics on facts for every
            -- dep: 17.8s vs 3.7s cold on VictoriaMetrics.
            staticcheck = false,
          },
        },
      },
    },
  },
}
