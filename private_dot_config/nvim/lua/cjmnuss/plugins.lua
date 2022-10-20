
-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

return require('packer').startup(function()
  use 'wbthomason/packer.nvim'
  use 'nvim-lua/plenary.nvim' -- almost all plugins need this
  use {'nvim-telescope/telescope.nvim',
  config = function ()
    vim.cmd("nnoremap <leader>f <cmd>lua require('telescope.builtin').find_files()<cr>")
    vim.cmd("nnoremap <leader>g <cmd>lua require('telescope.builtin').live_grep()<cr>")
    vim.cmd("nnoremap <leader>b <cmd>lua require('telescope.builtin').buffers()<cr>")
    vim.cmd("nnoremap <leader>h <cmd>lua require('telescope.builtin').help_tags()<cr>")
    vim.cmd("nnoremap <leader>r <cmd>lua require('telescope.builtin').registers()<cr>")
  end
  }

  -- essential plugins
  use 'tpope/vim-sensible'
  use 'tpope/vim-surround'
  use 'tpope/vim-sleuth'
  use 'tpope/vim-vinegar'
  use 'tpope/vim-commentary'
  use 'tpope/vim-repeat'
  use 'tpope/vim-unimpaired'
  use 'tpope/vim-fugitive'

  use({
  "folke/persistence.nvim",
  event = "BufReadPre", -- this will only start session saving when an actual file was opened
  module = "persistence",
  config = function()
    require("persistence").setup()
  end,
})


  use 'ntpeters/vim-better-whitespace'

  -- tmux integration
  use 'roxma/vim-tmux-clipboard'
  use {'christoomey/vim-tmux-navigator',
    config = function ()
      vim.cmd("let g:tmux_navigator_no_mappings = 1")
      vim.cmd("nnoremap <silent> <C-w>h :TmuxNavigateLeft<cr>")
      vim.cmd("nnoremap <silent> <C-w>j :TmuxNavigateDown<cr>")
      vim.cmd("nnoremap <silent> <C-w>k :TmuxNavigateUp<cr>")
      vim.cmd("nnoremap <silent> <C-w>l :TmuxNavigateRight<cr>")
      vim.cmd("nnoremap <silent> <C-w>\\ :TmuxNavigatePrevious<cr>")
    end
  }

  use {
  'lewis6991/gitsigns.nvim',
  config = function()
    require('gitsigns').setup()
  end
  }

  use {
    'ggandor/leap.nvim',
    config = function()
      require('leap').add_default_mappings()
    end
  }

  --
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }

  use {
    "nanozuki/tabby.nvim",
    config = function() require("tabby").setup() end,
  }

  -- buffers
  -- use {'akinsho/bufferline.nvim', tag = "*", requires = 'kyazdani42/nvim-web-devicons',
  -- config = function()
  --   vim.opt.termguicolors = true
  --   require("bufferline").setup()
  --   vim.cmd("nnoremap <silent>]b :BufferLineCycleNext<CR>")
  --   vim.cmd("nnoremap <silent>[b :BufferLineCyclePrev<CR>")

  --   vim.cmd("nnoremap <silent>]B :BufferLineMoveNext<CR>")
  --   vim.cmd("nnoremap <silent>[V :BufferLineMovePrev<CR>")
  -- end
  -- }


  -- color themes
  -- use 'projekt0n/github-nvim-theme'
  use 'shaunsingh/solarized.nvim'
  use {
    "mcchrish/zenbones.nvim",
    -- Optionally install Lush. Allows for more configuration or extending the colorscheme
    -- If you don't want to install lush, make sure to set g:zenbones_compat = 1
    -- In Vim, compat mode is turned on as Lush only works in Neovim.
    requires = "rktjmp/lush.nvim"
}
  use "EdenEast/nightfox.nvim"

end)
