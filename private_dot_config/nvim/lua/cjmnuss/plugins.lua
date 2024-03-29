
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
  use 'sunaku/tmux-navigate'

  use({ "iamcco/markdown-preview.nvim", run = "cd app && npm install", setup = function()
    vim.g.mkdp_filetypes = { "markdown" }
    vim.cmd([[
      function OpenMarkdownPreview (url)
        execute "silent ! open --new -a 'Google Chrome' --args --new-window " . a:url
      endfunction
      let g:mkdp_browserfunc = 'OpenMarkdownPreview'
    ]])
  end, ft = { "markdown" }, })

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
use { "catppuccin/nvim", as = "catppuccin" }

end)

