function PluginList ()

	-- Package Management
	use "wbthomason/packer.nvim" -- packer manages itself
	use "dstein64/vim-startuptime" -- measure startup time with `:StartupTime`
	use 'lewis6991/impatient.nvim' -- reduces startup time by ~50%
	use {"williamboman/mason.nvim", requires = {
		'RubixDev/mason-update-all',
		"jayp0521/mason-null-ls.nvim",
		"williamboman/mason-lspconfig.nvim",
	}}

	-- Themes
	use "folke/tokyonight.nvim"
	use "EdenEast/nightfox.nvim"
	use "rebelot/kanagawa.nvim"
	-- use "Mofiqul/dracula.nvim"
	-- use "navarasu/onedark.nvim"
	-- use "sainnhe/edge"
	-- use "savq/melange"
	-- use "Yazeed1s/minimal.nvim"
	-- use "kaiuri/nvim-juliana"

	-- Syntax
	use {
		"nvim-treesitter/nvim-treesitter",
		run = function() -- auto-update parsers on start: https://github.com/nvim-treesitter/nvim-treesitter/wiki/Installation#packernvim
			require("nvim-treesitter.install").update({ with_sync = true })
		end,
		requires = {
			"nvim-treesitter/nvim-treesitter-context",
			"nvim-treesitter/nvim-treesitter-textobjects",
			"p00f/nvim-ts-rainbow",
		}
	}
	use "mityu/vim-applescript" -- applescript syntax highlighting
	use "hail2u/vim-css3-syntax" -- better css syntax highlighting (until treesitter css looks decent…)

	-- LSP & Linting
	use "neovim/nvim-lspconfig"
	use "ray-x/lsp_signature.nvim"
	use {"jose-elias-alvarez/null-ls.nvim", requires =  "nvim-lua/plenary.nvim"}

	-- Completion & Suggestion
	use "mattn/emmet-vim" -- Emmet for CSS
	use "tversteeg/registers.nvim"
	use {"windwp/nvim-autopairs", requires = "hrsh7th/nvim-cmp"}
	use {"hrsh7th/nvim-cmp", requires = {
		"hrsh7th/cmp-buffer", -- completion sources
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-cmdline",
		"dmitmel/cmp-cmdline-history",
		"hrsh7th/cmp-emoji",
		"chrisgrieser/cmp-nerdfont",

		"hrsh7th/cmp-nvim-lsp", -- lsp
		"folke/neodev.nvim", -- lsp for nvim config

		"L3MON4D3/LuaSnip", -- snippet engine
		"saadparwaiz1/cmp_luasnip",
		"rafamadriz/friendly-snippets", -- collection of common snippets
	}}

	-- Appearance
	use "lukas-reineke/indent-blankline.nvim" -- indentation guides
	use "nvim-lualine/lualine.nvim" -- status line
	use "lewis6991/gitsigns.nvim"
	use "f-person/auto-dark-mode.nvim" -- auto-toggle themes with OS dark/light mode
	use "uga-rosa/ccc.nvim" -- color previews & color utilites
	-- use "folke/zen-mode.nvim" -- nvim version of Goyo; mostly for readable line length in markdown

	-- File Management & Switching
	use "tpope/vim-eunuch" -- file operation utilities
	use { "nvim-telescope/telescope.nvim", requires = {
		"nvim-lua/plenary.nvim",
		"kyazdani42/nvim-web-devicons",
		"nvim-telescope/telescope-ui-select.nvim",
	}}

	-- Operators
	use "kylechui/nvim-surround"
	use "tpope/vim-abolish" -- various case conversions
	use "gbprod/substitute.nvim" -- substitution operator, neovim version for vim-subversive
	use "numToStr/Comment.nvim"

	-- Text Objects
	use "andrewferrier/textobj-diagnostic.nvim" -- nvim diagnostics as text object
	use "michaeljsmith/vim-indent-object"

	-- Navigation
	use "mg979/vim-visual-multi" -- multi-cursor
	use "justinmk/vim-sneak"
	use "simrat39/symbols-outline.nvim" -- outline view for symbols

	-- Editing
	use "matze/vim-move" -- move lines with auto-indention (alternative: vim.unimpaired)
	use "AndrewRadev/splitjoin.vim"
	use "mbbill/undotree" -- undo history nagivation
end
