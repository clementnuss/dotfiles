-- general
lvim.log.level = "warn"
lvim.format_on_save = true
lvim.colorscheme = "solarized"
lvim.transparent_window = true

-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"
-- add your own keymapping
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
-- unmap a default keymapping
-- lvim.keys.normal_mode["<C-Up>"] = ""
-- edit a default keymapping
-- lvim.keys.normal_mode["<C-q>"] = ":q<cr>"

local _, actions = pcall(require, "telescope.actions")
lvim.builtin.telescope.defaults.mappings = {
  -- for input mode
  i = {
    ["<C-j>"] = actions.move_selection_next,
    ["<C-k>"] = actions.move_selection_previous,
    ["<C-n>"] = actions.cycle_history_next,
    ["<C-p>"] = actions.cycle_history_prev,
  },
  -- for normal mode
  n = {
    ["<C-j>"] = actions.move_selection_next,
    ["<C-k>"] = actions.move_selection_previous,
  },
}

-- Use which-key to add extra bindings with the leader-key prefix
lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }
lvim.builtin.which_key.mappings["t"] = {
  name = "+Trouble",
  r = { "<cmd>Trouble lsp_references<cr>", "References" },
  f = { "<cmd>Trouble lsp_definitions<cr>", "Definitions" },
  d = { "<cmd>Trouble lsp_document_diagnostics<cr>", "Diagnostics" },
  q = { "<cmd>Trouble quickfix<cr>", "QuickFix" },
  l = { "<cmd>Trouble loclist<cr>", "LocationList" },
  w = { "<cmd>Trouble lsp_workspace_diagnostics<cr>", "Diagnostics" },
}

lvim.builtin.dashboard.active = true
lvim.builtin.terminal.active = true
lvim.builtin.notify.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.show_icons.git = 1

-- if you don't want all the parsers change this to a table of the ones you want
lvim.builtin.treesitter.ensure_installed = {
  "bash",
  "c",
  "javascript",
  "json",
  "lua",
  "python",
  "typescript",
  "css",
  "rust",
  "java",
  "yaml",
}

lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enabled = true

-- local parser_configs = require("nvim-treesitter.parsers").get_parser_configs()
-- parser_configs.hcl = {
--   filetype = "hcl", "terraform",
-- }


-- -- Prettier configuration
-- local formatters = require "lvim.lsp.null-ls.formatters"
-- formatters.setup {
--   {
--     exe = "prettierd",
--     filetypes = {
--       "javascriptreact",
--       "javascript",
--       "typescriptreact",
--       "typescript",
--       "json",
--       "markdown",
--     },
--   },
-- }

local linters = require "lvim.lsp.null-ls.linters"
linters.setup {
  { exe = "markdownlint", filetypes = { "markdown" }},
}

-- Additional Plugins
lvim.plugins = {
  {
    "folke/trouble.nvim",
    cmd = "TroubleToggle",
  },
  {
    "ggandor/lightspeed.nvim",
    event = "BufRead",
  },
  {
    "tpope/vim-surround",
    keys = {"c", "d", "y"},
    config = function ()
      -- vim.cmd("let g:surround_no_mappings = 1")
    end
  },
  {
    "folke/persistence.nvim",
      event = "BufReadPre", -- this will only start session saving when an actual file was opened
      module = "persistence",
      config = function()
        require("persistence").setup {
          dir = vim.fn.expand(vim.fn.stdpath "config" .. "/session/"),
          options = { "buffers", "curdir", "tabpages", "winsize" },
        }
    end,
  },
  {"shaunsingh/solarized.nvim"},
  {"christoomey/vim-tmux-navigator",
    config = function ()
      vim.cmd("let g:tmux_navigator_no_mappings = 1")
      vim.cmd("nnoremap <silent> <C-w>h :TmuxNavigateLeft<cr>")
      vim.cmd("nnoremap <silent> <C-w>j :TmuxNavigateDown<cr>")
      vim.cmd("nnoremap <silent> <C-w>k :TmuxNavigateUp<cr>")
      vim.cmd("nnoremap <silent> <C-w>l :TmuxNavigateRight<cr>")
      vim.cmd("nnoremap <silent> <C-w>\\ :TmuxNavigatePrevious<cr>")
    end
  },
  {"roxma/vim-tmux-clipboard"},
  {"puremourning/vimspector",
      config = function ()
        vim.cmd("let g:vimspector_enable_mappings = 'HUMAN'")
      end
  },
}

vim.opt.timeoutlen = 300
vim.opt.relativenumber = true

lvim.builtin.which_key.mappings["S"]= {
    name = "Session",
    c = { "<cmd>lua require('persistence').load()<cr>", "Restore last session for current dir" },
    l = { "<cmd>lua require('persistence').load({ last = true })<cr>", "Restore last session" },
    Q = { "<cmd>lua require('persistence').stop()<cr>", "Quit without saving session" },
  }

-- Autocommands (https://neovim.io/doc/user/autocmd.html)
-- lvim.autocommands.custom_groups = {
--   { "BufWinEnter", "*.lua", "setlocal ts=8 sw=8" },
-- }
