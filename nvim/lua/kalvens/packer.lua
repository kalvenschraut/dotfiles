-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
	-- Packer can manage itself
	use 'wbthomason/packer.nvim'

	use {
		'nvim-telescope/telescope.nvim', tag = '0.1.x',
		requires = { 'nvim-lua/plenary.nvim', 'BurntSushi/ripgrep' }
	}

	use { "ellisonleao/gruvbox.nvim" }

	use('nvim-treesitter/nvim-treesitter', { run = ':TSUpdate' })

	use('nvim-treesitter/playground')
	use('ThePrimeagen/harpoon')
	use('mbbill/undotree')
	use('tpope/vim-fugitive')

	--- {{{ Language Server packages
	use {
		'VonHeikemen/lsp-zero.nvim',
		branch = 'v2.x',
		requires = {
			-- LSP Support
			{ 'neovim/nvim-lspconfig' },
			{
				'williamboman/mason.nvim',
				run = function()
					pcall(vim.cmd, 'MasonUpdate')
				end,
			},
			{ 'williamboman/mason-lspconfig.nvim' },

			-- Autocompletion
			{ 'hrsh7th/nvim-cmp' },
			{ 'hrsh7th/cmp-nvim-lsp' },
			{ 'L3MON4D3/LuaSnip' },

			{ 'onsails/lspkind.nvim' }
		}

	}
	use('jose-elias-alvarez/null-ls.nvim')
	use {
		'davidmh/cspell.nvim',
		requires = {
			'nvim-lua/plenary.nvim'
		}
	}
	-- }}}

	-- {{{ Debug Adapters
	use('mfussenegger/nvim-dap');
	use {
		"microsoft/vscode-js-debug",
		opt = true,
		run = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out"
	}
	-- }}}

	-- Adds buffers at the top
	use { 'akinsho/bufferline.nvim', tag = "*", requires = 'nvim-tree/nvim-web-devicons' }

	-- {{{ Copilot Packages
	use {
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			require("copilot").setup()
		end
	}
	use {
		"zbirenbaum/copilot-cmp",
		after = { "copilot.lua" },
		config = function()
			require("copilot_cmp").setup()
		end
	}
	-- }}}
end)
