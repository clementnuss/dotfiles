local ss = require("smart-splits")

vim.keymap.set("n", "<A-h>", ss.move_cursor_left)
vim.keymap.set("n", "<A-k>", ss.move_cursor_up)
vim.keymap.set("n", "<A-j>", ss.move_cursor_down)
vim.keymap.set("n", "<A-l>", ss.move_cursor_right)
vim.keymap.set("n", "<A-\\>", "<C-w>p")

vim.keymap.set("n", "<C-h>", ss.resize_left)
vim.keymap.set("n", "<C-j>", ss.resize_down)
vim.keymap.set("n", "<C-k>", ss.resize_up)
vim.keymap.set("n", "<C-l>", ss.resize_right)

vim.keymap.set("n", "<leader><leader>h", ss.swap_buf_left)
vim.keymap.set("n", "<leader><leader>j", ss.swap_buf_down)
vim.keymap.set("n", "<leader><leader>k", ss.swap_buf_up)
vim.keymap.set("n", "<leader><leader>l", ss.swap_buf_right)
