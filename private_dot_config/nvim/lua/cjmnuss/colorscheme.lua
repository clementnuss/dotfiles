
vim.opt.background = "light"

 vim.g.zenbones = {
 	darken_noncurrent_window = true,
 }

 vim.cmd('set termguicolors')

 local colorscheme = "zenbones"

 local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
 if not status_ok then
 	vim.notify("colorscheme " .. colorscheme .. " not found!")
 	return
 end

