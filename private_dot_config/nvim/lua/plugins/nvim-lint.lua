-- opts, not config: merges with LazyVim's lint setup (events, extras' linters)
return {
  "mfussenegger/nvim-lint",
  opts = {
    linters_by_ft = {
      go = { "golangcilint" },
      yaml = { "yamllint" },
      markdown = { "markdownlint-cli2" },
    },
  },
}
