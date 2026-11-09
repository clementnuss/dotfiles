-- center mode: empty side windows keep the text in the middle of a wide screen
local centered = require("config.util").centered

-- in center mode the docked tree would sit at the far-left edge; float it instead
local function explorer(dir)
  return function()
    require("neo-tree.command").execute({
      toggle = true,
      dir = dir(),
      position = centered() and "float" or nil,
    })
  end
end

return {
  {
    "shortcuts/no-neck-pain.nvim",
    version = "*",
    cmd = "NoNeckPain",
    keys = {
      {
        "<leader>z",
        function()
          if not centered() and package.loaded["neo-tree"] then
            vim.cmd("Neotree close")
          end
          vim.cmd("NoNeckPain")
        end,
        desc = "Center Mode",
      },
    },
    opts = {
      -- ~3/5 of the 27" full-width (388 cols); narrower panes stay uncentered
      width = 230,
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = {
      { "<leader>fe", explorer(LazyVim.root), desc = "Explorer NeoTree (Root Dir)" },
      { "<leader>fE", explorer(vim.uv.cwd), desc = "Explorer NeoTree (cwd)" },
    },
  },
}
