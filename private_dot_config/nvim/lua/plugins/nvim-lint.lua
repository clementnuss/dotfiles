-- opts, not config: merges with LazyVim's lint setup (events, extras' linters)
return {
  "mfussenegger/nvim-lint",
  opts = {
    linters_by_ft = {
      go = { "golangcilint" },
      yaml = { "yamllint" },
      markdown = { "markdownlint-cli2" },
    },
    linters = {
      -- cli2 has no global config lookup; this is a base, repo configs override it
      ["markdownlint-cli2"] = {
        prepend_args = { "--config", vim.fn.expand("~/.config/markdownlint/.markdownlint.yaml") },
      },
    },
  },
}
