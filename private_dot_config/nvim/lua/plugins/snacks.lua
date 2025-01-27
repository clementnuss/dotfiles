local direction_keys = {
  h = 'left',
  j = 'down',
  k = 'up',
  l = 'right',
}

-- Terminal Mappings
local function term_nav(dir)
  ---@param self snacks.terminal
  return function(self)
    return self:is_floating() and "<m-" .. dir .. ">" or vim.schedule(function()
      require("smart-splits")["move_cursor_" .. direction_keys[dir]]()
    end)
  end
end

return {

  -- Snacks utils
  {
    "snacks.nvim",
    opts = {
      terminal = {
        win = {
          keys = {
            nav_h = { "<M-h>", term_nav("h"), desc = "Go to Left Window", expr = true, mode = "t" },
            nav_j = { "<M-j>", term_nav("j"), desc = "Go to Lower Window", expr = true, mode = "t" },
            nav_k = { "<M-k>", term_nav("k"), desc = "Go to Upper Window", expr = true, mode = "t" },
            nav_l = { "<M-l>", term_nav("l"), desc = "Go to Right Window", expr = true, mode = "t" },
          },
        },
      },
    },
  },
}
