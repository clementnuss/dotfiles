
-- vim.opt.background = "light"

 vim.cmd('set termguicolors')

 local colorscheme = "dayfox"

 local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
 if not status_ok then
 	vim.notify("colorscheme " .. colorscheme .. " not found!")
 	return
 end

require('lualine').setup()

-- https://github.com/navarasu/onedark.nvim
-- require('onedark').setup {
--     style = 'light'
-- }
-- require('onedark').load()
