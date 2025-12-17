return {
  -- Override nvim-cmp keybindings
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require("cmp")

      -- Override the default mapping to use Ctrl+Y instead of Ctrl+Space
      opts.mapping = vim.tbl_extend("force", opts.mapping or {}, {
        -- Use Ctrl+Y to trigger completion (instead of Ctrl+Space which is tmux prefix)
        ["<C-y>"] = cmp.mapping.complete(),

        -- Keep other useful mappings
        ["<C-Space>"] = cmp.mapping(function()
          -- Do nothing - let tmux handle it
        end, { "i", "c" }),
      })

      return opts
    end,
  },
}
