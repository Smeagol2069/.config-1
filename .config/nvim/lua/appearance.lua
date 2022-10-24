require("utils")

--------------------------------------------------------------------------------
-- custom highlights
-- have to wrapped in function and regularly called due to auto-dark-mode
-- regularly resetting the theme
function customHighlights()
	-- Diagnostics/Spell: use straight underlines instead of curly underlines,
	-- since the latter look weird with Neovide
	cmd[[highlight DiagnosticUnderlineError gui=underline]]
	cmd[[highlight DiagnosticUnderlineWarn gui=underline]]
	cmd[[highlight DiagnosticUnderlineHint gui=underline]]
	cmd[[highlight DiagnosticUnderlineInfo gui=underline]]

	cmd[[highlight SpellLocal gui=underline]]
	cmd[[highlight SpellRare gui=underline]]
	cmd[[highlight SpellCap gui=underline]]
	cmd[[highlight SpellBad gui=underline]]

	-- URLs
	cmd[[highlight urls cterm=underline term=underline gui=underline]]
	fn.matchadd('urls', [[http[s]\?:\/\/[[:alnum:]%\/_#.\-?:]*]])
end

customHighlights()

-- mixed whitespace
cmd[[highlight! def link MixedWhiteSpace Folded]]
cmd[[call matchadd('MixedWhiteSpace', '^\(\t\+ \| \+\t\)[ \t]*')]]

-- Annotations
cmd[[highlight! def link myAnnotations Todo]] -- use same styling as "TODO"
cmd[[call matchadd('myAnnotations', 'INFO\|TODO\|NOTE\|WARNING\|WARN\|REQUIRED') ]]

--------------------------------------------------------------------------------

-- GUTTER
opt.signcolumn = "yes:1"

require('gitsigns').setup{
	max_file_length = 15000,
	preview_config	= { border = borderStyle },
}

--------------------------------------------------------------------------------
-- DIAGNOSTICS

-- ▪︎▴• ▲  
-- https://www.reddit.com/r/neovim/comments/qpymbb/lsp_sign_in_sign_columngutter/
local signs = {
	Error = "",
	Warn = "▲",
	Info = "" ,
	Hint = "",
}
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl }) ---@diagnostic disable-line: redundant-parameter, param-type-mismatch
end

--------------------------------------------------------------------------------

-- STATUS LINE (LuaLine)
local function alternateFile()
	local altFile = api.nvim_exec('echo expand("#:t")', true)
	local curFile = api.nvim_exec('echo expand("%:t")', true)
	if altFile == curFile or altFile == "" then return "" end
	return "# "..altFile
end

local function currentFile() -- using this function instead of default filename, since this does not show "[No Name]" for Telescope
	local curFile = api.nvim_exec('echo expand("%:t")', true)
	if not(curFile) or curFile == "" then return "" end
	return "%% "..curFile -- "%" is lua's escape character and therefore needs to be escaped itself
end

local function mixedIndentation()
	if bo.filetype == "css" or bo.filetype == "markdown" or vim.tbl_contains(specialFiletypes, bo.filetype) then return "" end

	local hasTabs = fn.search("^\t", "nw") ~= 0
	local hasSpaces = fn.search("^ ", "nw") ~= 0
	local mixed = fn.search([[^\(\t\+ \| \+\t\)]], "nw") ~= 0

	if (hasSpaces and hasTabs) or mixed then
		return "  mixed "
	elseif hasSpaces and not(bo.expandtab) then
		return " expandtab"
	elseif hasTabs and bo.expandtab then
		return " noexpandtab"
	end
	return ""
end

local secSeparators
if isGui() then
	secSeparators = { left = ' ', right = ' '} -- nerdfont: 'nf-ple'
else
	secSeparators = { left = '', right = ''}
end

require('lualine').setup {
	sections = {
		lualine_a = {'mode'},
		lualine_b = {{ currentFile }},
		lualine_c = {{ alternateFile }},
		lualine_x = {'diff'},
		lualine_y = {'diagnostics', {mixedIndentation}},
		lualine_z = {'location', 'progress'},
	},
	options = {
		theme = 'auto',
		globalstatus = true,
		component_separators = { left = '', right = ''},
		section_separators = secSeparators,
	},
}

