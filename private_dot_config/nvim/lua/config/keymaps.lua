local ss = require("smart-splits")

-- no-neck-pain's padding windows bounce focus straight back, so smart-splits never
-- sees an edge and never hands off to tmux: treat a padding neighbour as the edge
local function move(dir, key)
  return function()
    local nr = vim.fn.winnr(key)
    if nr ~= vim.fn.winnr() and vim.bo[vim.fn.winbufnr(nr)].filetype == "no-neck-pain" then
      require("smart-splits.backend").move(dir)
    else
      ss["move_cursor_" .. dir]()
    end
  end
end

vim.keymap.set("n", "<A-h>", move("left", "h"))
vim.keymap.set("n", "<A-k>", ss.move_cursor_up)
vim.keymap.set("n", "<A-j>", ss.move_cursor_down)
vim.keymap.set("n", "<A-l>", move("right", "l"))
vim.keymap.set("n", "<A-\\>", "<C-w>p")

vim.keymap.set("n", "<C-h>", ss.resize_left)
vim.keymap.set("n", "<C-j>", ss.resize_down)
vim.keymap.set("n", "<C-k>", ss.resize_up)
vim.keymap.set("n", "<C-l>", ss.resize_right)

vim.keymap.set("n", "<leader><leader>h", ss.swap_buf_left)
vim.keymap.set("n", "<leader><leader>j", ss.swap_buf_down)
vim.keymap.set("n", "<leader><leader>k", ss.swap_buf_up)
vim.keymap.set("n", "<leader><leader>l", ss.swap_buf_right)
