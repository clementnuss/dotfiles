
-- vim.opt.background = "light"

vim.cmd('set termguicolors')
vim.cmd.colorscheme "catppuccin-latte"

require('lualine').setup()

require("catppuccin").setup({
    integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        leap = true,
    }
})
