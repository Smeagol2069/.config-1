require("utils")
-- INFO: required order of setup() calls is
-- mason, mason-config, nvim-dev, lspconfig
-- https://github.com/williamboman/mason-lspconfig.nvim#setup

--------------------------------------------------------------------------------
-- https://github.com/ray-x/lsp_signature.nvim#full-configuration-with-default-values
require"lsp_signature".setup{
	floating_window = false, -- don't show by default
	hint_enable = true, -- virtual text hint

	floating_window_above_cur_line = false, -- avoids overlap with cmp window
	max_width = 60,
	max_height = 7,
	handler_opts = { border = borderStyle },
	toggle_key = "<C-h>", -- toggle signature on and off in insert mode,  e.g. toggle_key = '<M-x>'

	hint_prefix = " ",
}

--------------------------------------------------------------------------------
-- DIAGNOTICS (in general, also applies to nvim-lint etc.)
local opts = { noremap=true, silent=true }
keymap('n', 'ge', function () vim.diagnostic.goto_next({wrap=true, float=false}) end, opts)
keymap('n', 'gE', function () vim.diagnostic.goto_prev({wrap=true, float=false}) end, opts)

vim.diagnostic.config{
	virtual_text = {
		format = function (diagnostic)
			if diagnostic.source == "stylelint" then
				return diagnostic.message -- stylelint already includes the code in the message
			else
				return diagnostic.message.." ("..tostring(diagnostic.code)..")"
			end
		end,
	},
	float = {
		border = borderStyle,
		max_width = 50,
		format = function (diagnostic)
			if not(diagnostic.source) then diagnostic.source = "" end
			if diagnostic.source == "stylelint" then
				return diagnostic.message.." ["..diagnostic.source.."]"
			else
				return diagnostic.message.." ("..tostring(diagnostic.code)..", "..diagnostic.source..")"
			end
		end,
	}
}

-- show diagnostic under cursor as float
opt.updatetime = 1000 -- ms until float is shown
augroup("diagnostic-float", {})
autocmd("CursorHold", {
	group = "diagnostic-float",
	callback = function () vim.diagnostic.open_float{focusable=false} end, -- allow focussable for other diagnostic floats like hover info
})

-- textobj diagnostic plugin
require("textobj-diagnostic").setup{create_default_keymaps = false}
keymap({"x", "o"}, "id", function() require("textobj-diagnostic").next_diag_inclusive() end, { silent = true })

--------------------------------------------------------------------------------

require("mason").setup({
	ui = {
		border = borderStyle,
		icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" }
	}
})

--------------------------------------------------------------------------------

require("mason-lspconfig").setup({
	-- mason-lspconfig uses the lspconfig servernames, not mason servernames
	-- https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
	ensure_installed = {
		"sumneko_lua",
		"yamlls",
		"eslint", -- ts/js
		"tsserver", -- ts/js
		"marksman", -- markdown
		"jsonls",
		"cssls",
		-- "stylelint_lsp", -- not using lsp due to: https://github.com/bmatcuk/stylelint-lsp/issues/36
		-- REQUIRED: new servers also need to be set up further below
	},
})

-- fallback for languages without an action LSP
keymap('n', 'gs', function() telescope.treesitter() end, {silent = true})

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr) ---@diagnostic disable-line: unused-local
	local bufopts = { silent=true, buffer=true }
	keymap('n', 'gd', function() telescope.lsp_definitions() end, bufopts)
	keymap('n', 'gD', function() telescope.lsp_references() end, bufopts)

	keymap('n', 'gS', ":SymbolsOutline<CR>", bufopts)
	keymap('n', 'gy', function() telescope.lsp_type_definitions() end, bufopts)
	keymap('n', '<leader>R', vim.lsp.buf.rename, bufopts)
	keymap('n', '<leader>a', vim.lsp.buf.code_action, bufopts)
	keymap('n', '<leader>h', vim.lsp.buf.hover, bufopts) -- docs popup

	if client.name ~= "cssls" then -- to not override the navigation marker search for css files
		keymap('n', 'gs', function() telescope.lsp_document_symbols() end, bufopts) -- overrides treesitter symbols browsing
	end
end

--------------------------------------------------------------------------------
-- LSP-SERVER-SPECIFIC SETUP
local lspConfig = require('lspconfig')

-- Enable snippet capability for completion
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

require("lua-dev").setup { -- INFO: this block must come before LSP setup
	library = { enabled = true, plugins = false }
}

lspConfig['sumneko_lua'].setup{
	on_attach = on_attach,
	capabilities = capabilities,
	settings = { -- https://github.com/sumneko/lua-language-server/wiki/Settings
		Lua = {
			runtime = { version = 'LuaJIT', },  -- used by neovim
			completion = {
				callSnippet = "both",
				keywordSnippet = "both",
			},
			diagnostics = {
				globals = {"vim", "use", "martax"},
				disable = {
					"trailing-space",
					"lowercase-global",
				},
			},
			workspace = {
				library =  {
					home.."/.hammerspoon/Spoons/EmmyLua.spoon/annotations",
				}
			},
			telemetry = { enable = false },
			hint = {
				enable = true,
				settype = true
			},
		}
	}
}

lspConfig['cssls'].setup{
	on_attach = on_attach,
	capabilities = capabilities,
	settings = {
		css = {
			lint = {
				vendorPrefix = "ignore",
				duplicateProperties = "error",
			},
			colorDecorators = { enable = true }, -- does not seem to work?
		}
	}
}

-- lspConfig['stylelint_lsp'].setup{
-- 	on_attach = on_attach,
-- 	capabilities = capabilities,
-- 	root_dir = function() return vim.fn.getcwd() end, -- needs root-dir to work
-- 	settings =  {
-- 		stylelintplus =  {
-- 			configFile = home.."/.stylelintrc.json",
-- 		}
-- 	}
-- }

lspConfig['tsserver'].setup{
	on_attach = on_attach,
	capabilities = capabilities,
}

lspConfig['marksman'].setup{
	on_attach = on_attach,
	capabilities = capabilities,
}

lspConfig['jsonls'].setup{
	on_attach = on_attach,
	capabilities = capabilities,
}

lspConfig['eslint'].setup{
	on_attach = on_attach,
	capabilities = capabilities,
}

