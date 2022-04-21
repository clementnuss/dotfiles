
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
    vim.cmd("nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>")
    vim.cmd("nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>")
    vim.cmd("nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>")
    vim.cmd("nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>")
    vim.cmd("nnoremap <leader>fr <cmd>lua require('telescope.builtin').registers()<cr>")
  end
  }

  -- tmux integration
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
  use 'roxma/vim-tmux-clipboard'

  -- essential plugins
  use 'tpope/vim-surround'
  use 'tpope/vim-sensible'
  use 'tpope/vim-sleuth'
  use 'tpope/vim-vinegar'
  use 'tpope/vim-commentary'
  use 'tpope/vim-repeat'

  use 'folke/which-key.nvim'
  use {
  'lewis6991/gitsigns.nvim',
  config = function()
    require('gitsigns').setup()
  end
  }
  use 'ggandor/lightspeed.nvim'

  -- buffers
  use 'akinsho/nvim-bufferline.lua'

  -- color themes
  use 'projekt0n/github-nvim-theme'
--  use 'shaunsingh/solarized.nvim'
--  use {
--    "mcchrish/zenbones.nvim",
--    -- Optionally install Lush. Allows for more configuration or extending the colorscheme
--    -- If you don't want to install lush, make sure to set g:zenbones_compat = 1
--    -- In Vim, compat mode is turned on as Lush only works in Neovim.
--    requires = "rktjmp/lush.nvim"
--}

end)
