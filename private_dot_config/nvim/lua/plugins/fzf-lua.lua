return {
  "ibhagwan/fzf-lua",
  opts = {
    winopts = {
      preview = {
        -- sizing it calls nvim_win_text_height over the whole buffer, which forces a
        -- synchronous full treesitter pass: ~25s of frozen UI on VictoriaMetrics' CHANGELOG.md
        scrollbar = false,
      },
    },
  },
}
