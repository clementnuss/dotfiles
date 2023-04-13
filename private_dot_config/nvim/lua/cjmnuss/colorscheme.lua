
-- vim.opt.background = "light"

 vim.cmd('set termguicolors')

 -- local colorscheme = "dayfox"

 -- local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
 -- if not status_ok then
 -- 	vim.notify("colorscheme " .. colorscheme .. " not found!")
 -- 	return
 -- end

vim.cmd('colorscheme github_light')

require('lualine').setup()

