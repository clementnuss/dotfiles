local o = vim.opt

o.mouse = "a"
o.expandtab = true -- Use spaces instead of tabs
o.shiftwidth = 2 -- Size of an indent
o.tabstop = 2 -- Number of spaces tabs count for

-- o.smartindent = true -- Insert indents automatically
o.smartcase = true -- Don't ignore case with capitals

o.hidden = true -- Enable modified buffers in background
o.ignorecase = true -- Ignore case
o.undofile = true -- enable persistent undo
o.updatetime = 300 -- faster completion (4000ms default)
o.inccommand = "split" -- Live preview for search and replace
o.joinspaces = false -- No double spaces with join after a dot
o.signcolumn = "yes" -- always show the sign column, otherwise it would shift the text each time
o.showmode = false -- we don't need to see things like -- INSERT -- anymore
o.scrolloff = 8 -- Lines of context
o.shiftround = true -- Round indent
o.sidescrolloff = 8 -- Columns of context
o.splitbelow = true -- Put new windows below current
o.splitright = true -- Put new windows right of current
o.wildmode = "list:longest" -- Command-line completion mode
o.list = false -- Show some invisible characters (tabs...)
o.number = true -- Print line number
o.relativenumber = true -- Relative line numbers
o.wrap = true -- Enable line wrap
o.cmdheight = 1 -- More space to display messages
o.timeoutlen = 200 -- Don't wait more that 200ms for normal mode commands
o.termguicolors = true -- True color support

-- o.shada = { "!", "'1000", "<50", "s10", "h" } -- remember stuff across sessions
-- o.laststatus = 3 -- use global status line

-- vim.opt.shortmess:append("c")

-- vim.api.nvim_command("set noswapfile")

-- vim.cmd([[ set iskeyword+=- ]]) -- this treats dash separated words (i.e: dash-separated) as one word
-- vim.cmd([[ set diffopt+=internal,algorithm:histogram ]]) -- better diff algorithm

-- o.foldmethod = "expr"
-- o.foldexpr = "nvim_treesitter#foldexpr()"
-- o.foldnestmax = 5
-- o.foldminlines = 1
-- o.foldenable = false -- folds are open per default. use zx to fold when opend with telescope
local group_cdpwd = vim.api.nvim_create_augroup("group_cdpwd", { clear = true })
vim.api.nvim_create_autocmd("VimEnter", {
  group = group_cdpwd,
  pattern = "*",
  callback = function()
    vim.api.nvim_set_current_dir(vim.fn.expand("%:p:h"))
  end,
})

