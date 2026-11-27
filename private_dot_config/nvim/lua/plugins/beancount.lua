-- no LazyVim extra for beancount; listing the server makes mason-lspconfig install it
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        beancount = {},
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "beancount" } },
  },
}
