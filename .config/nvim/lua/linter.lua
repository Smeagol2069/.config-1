require("utils")
-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTIN_CONFIG.md
--------------------------------------------------------------------------------

local lintersAndFormatters = {
	"eslint_d",
	"markdownlint",
	"shellcheck",
	"yamllint",
	-- stylelint not added due to extra plugins
}
-- INFO: linters also need to be added as source below

--------------------------------------------------------------------------------

local null_ls = require("null-ls")

local forceZshForShellcheck = {
	extra_filetypes = {"zsh"},
	extra_args = {"--shell=bash"},
}

null_ls.setup{
	sources = {

		-- `bashls` and `diagnosticls` both do not work for zsh shellcheck; `efm` depends on go
		null_ls.builtins.diagnostics.zsh,
		null_ls.builtins.diagnostics.shellcheck.with(forceZshForShellcheck),
		null_ls.builtins.code_actions.shellcheck.with(forceZshForShellcheck),

		null_ls.builtins.diagnostics.stylelint.with{ -- not using stylelint-lsp due to: https://github.com/bmatcuk/stylelint-lsp/issues/36
			extra_args = { "--quiet" }, -- only errors, no warnings
		},

		null_ls.builtins.code_actions.eslint_d,
		null_ls.builtins.diagnostics.eslint_d.with{
		},

		null_ls.builtins.diagnostics.yamllint.with{
			extra_args = {"--config", fn.expand("~/.config/yamllint/config/.yamllint.yaml")},
		},

		null_ls.builtins.diagnostics.markdownlint.with{
		},

	},
}

--------------------------------------------------------------------------------
-- mason-null-ls should be loaded after null-ls and mason https://github.com/jayp0521/mason-null-ls.nvim#setup

require("mason-null-ls").setup{
	-- these require the null-ls name, not the mason name: https://github.com/jayp0521/mason-null-ls.nvim#available-null-ls-sources
	ensure_installed = lintersAndFormatters
}
