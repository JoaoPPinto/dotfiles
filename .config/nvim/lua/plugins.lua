return {
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  {'nvim-tree/nvim-tree.lua', --'preservim/nerdtree',
    dependencies = {
      --'ryanoasis/vim-devicons'
      'nvim-tree/nvim-web-devicons'
    },
    config = function()
      require("nvim-tree").setup({
        sync_root_with_cwd = true,
	respect_buf_cwd = true,
	update_focused_file = {
          enable = true,
	  update_root = true
	}
      })
    end
  },
  {'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
        local configs = require('nvim-treesitter.configs')
        
        configs.setup({
            highlight = { enable = true }
        })
    end,
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'nvim-treesitter/nvim-treesitter-context'
    }
  },
  {'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim',
        config = function ()
	  require("mason").setup({
            ui = {
              icons = {
                package_installed = "✓",
                package_pending = "➜",
                package_uninstalled = "✗"
             }
            }
	  })
        end
      },
      { 'williamboman/mason-lspconfig.nvim',
        config = function()
	  require("mason-lspconfig").setup({
	    ensure_installed = { "terraformls", "tflint", "trivy", "shellcheck", "rust_analyzer", "ansiblels" }
	  })
	end
      }
    }
  },
  {'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'saadparwaiz1/cmp_luasnip',
      { 'L3MON4D3/LuaSnip',
        dependencies = { 'rafamadriz/friendly-snippets' }
      },
      {
        "zbirenbaum/copilot-cmp",
	dependencies = {
	  'zbirenbaum/copilot.lua',
	  cmd = "Copilot",
	  event = "InsertEnter",
	  config = function()
            require("copilot").setup({
	      suggestion = { enabled = false },
	      panel = { enabled = false }
	    })
	  end
	},
        config = function ()
          require("copilot_cmp").setup()
        end
      },
    }
  },
  { 'echasnovski/mini.pairs', version = false, config = function ()
      require('mini.pairs').setup()
    end
  },
  {
    'lewis6991/gitsigns.nvim',
    config = function ()
      require('gitsigns').setup()
    end
  },
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    }
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require("lualine").setup {}
    end
  },
  {'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },
  {
    'ahmedkhalf/project.nvim',
    config = function()
      require("project_nvim").setup {}
    end  
  }
}
