local opts = { noremap = true, silent = true }
local opts_expr = { noremap = true, silent = true, expr = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap

-- set space as new leader
keymap("", "<space>", "<nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- neozoom
-- keymap("n", "<leader>z", ":NeoZoomToggle<cr>", opts)

-- jj as <esc>
keymap("i", "jj", "<esc>", opts)

-- Shift + J/K moves selected lines down/up in visual mode
keymap("v", "J", ":m '>+1<CR>gv=gv", opts)
keymap("v", "K", ":m '<-2<CR>gv=gv", opts)

-- Stay in indent mode
-- keymap("v", "<", "<gv", opts)
-- keymap("v", ">", ">gv", opts)

-- EasyAlign
-- keymap("n", "ga", "<plug>(EasyAlign)", opts)
-- keymap("x", "ga", "<plug>(EasyAlign)", opts)

-- nvim.tree settings
-- vim.g.nvim_tree_width = "15%"

-- symbols settings
-- vim.g.symbols_outline = {
-- 	auto_close = true,
-- }

-- toggleterm
keymap("n", "<leader>T", ":ToggleTerm<cr>", opts)

-- -- yode
-- keymap("v", "<leader>yy", ":YodeCreateSeditorFloating<cr>", opts)
-- keymap("n", "<leader>yd", ":YodeBufferDelete<cr>", opts)
