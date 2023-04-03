
-- vim.opt.background = "light"

 vim.cmd('set termguicolors')

 -- local colorscheme = "dayfox"

 -- local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
 -- if not status_ok then
 -- 	vim.notify("colorscheme " .. colorscheme .. " not found!")
 -- 	return
 -- end

require("github-theme").setup({
  theme_style = "light",
  -- function_style = "italic",
  -- sidebars = {"qf", "vista_kind", "terminal", "packer"},

  -- Change the "hint" color to the "orange" color, and make the "error" color bright red
  -- colors = {hint = "orange", error = "#ff0000"},

--   -- Overwrite the highlight groups
--   overrides = function(c)
--     return {
--       htmlTag = {fg = c.red, bg = "#282c34", sp = c.hint, style = "underline"},
--       DiagnosticHint = {link = "LspDiagnosticsDefaultHint"},
--       -- this will remove the highlight groups
--       TSField = {},
--     }
--   end
})

-- require('solarized').set()

require('lualine').setup()

-- https://github.com/navarasu/onedark.nvim
-- require('onedark').setup {
--     style = 'light'
-- }
