-- https://github.com/nvim-telescope/telescope.nvim#telescope-setup-structure

require("telescope").setup {
	defaults = {
		selection_caret = "⟐ ",
		prompt_prefix = "❱ ",
		path_display = { "tail" },
		file_ignore_patterns = {
			"packer_compiled.lua",
			".DS_Store",
			".git/",
			".spl",
			".log",
			"node_modules",
			".png",
		},
		mappings = {
			i = {
				["<Esc>"] = "close", -- close w/ one esc
				["?"] = "which_key",
			},
		},
		layout_strategy = 'horizontal',
		layout_config = {
			horizontal = {
				height = 0.95,
				preview_cutoff = 70,
				width = 0.92
			},
			bottom_pane = {
				height = 12,
				preview_cutoff = 70,
			},
		},
	},
	pickers = {
		lsp_references = {
			prompt_prefix='⬅️',
			show_line=false,
			trim_text=true,
			include_declaration=false,
			initial_mode = "normal",
		},
		lsp_definitions = {
			prompt_prefix='➡️',
			show_line=false,
			trim_text=true,
			initial_mode = "normal",
		},
		lsp_document_symbols = { prompt_prefix='* ', show_line=false},
		treesitter = { show_line=false, prompt_prefix=' ' },
		find_files = { cwd='%:p:h', prompt_prefix=' ', hidden=true },
		keymaps = { prompt_prefix='? ' },
		oldfiles = { prompt_prefix=' ' },
		highlights = { prompt_prefix='🎨' },
		buffers = {
			prompt_prefix='﬘ ',
			ignore_current_buffer = true,
			initial_mode = "normal",
			sort_mru = true,
		},
		live_grep = {
			cwd='%:p:h',
			disable_coordinates=true,
			prompt_prefix=' ',
		},
		spell_suggest = {
			initial_mode = "normal",
			prompt_prefix = "暈",
			theme = "cursor",
		},
		colorscheme = {
			enable_preview = true,
			prompt_prefix='',
			layout_strategy = "bottom_pane",
		},
	},
	extensions = {
		["ui-select"] = {
			initial_mode = "normal",
			prompt_prefix = " ",
			theme = "cursor",
		}
	}
}
-- use telescope for selections like code actions
require("telescope").load_extension("ui-select")
