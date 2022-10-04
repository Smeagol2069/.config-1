require("utils")

--------------------------------------------------------------------------------
-- UI ELEMENTS
-- partially overriden when using a theme

-- cursor
opt.guicursor = "n-sm:block,i-ci-c-ve:ver25,r-cr-o-v:hor20"
opt.linespace = 3 -- px, similar to line height

-- Ruler
cmd[[highlight ColorColumn ctermbg=DarkGrey guibg=black]] -- https://www.reddit.com/r/neovim/comments/me35u9/lua_config_to_set_highlight/

-- Active Line
cmd[[highlight CursorLine term=none cterm=none guibg=black ctermbg=black]]

-- Current Word Highlight (from Coc)
cmd[[highlight CocHighlightText term=underline cterm=underline]]

-- TreeSitter Context Line
cmd[[highlight TreesitterContext ctermbg=black guibg=DarkGrey]]

-- Indentation Lines
cmd[[highlight IndentBlanklineChar ctermfg=DarkGrey guifg=DarkGrey]]

-- Comments
cmd[[highlight Comment ctermfg=grey]]

-- Popupmenus
cmd[[highlight Pmenu ctermbg=DarkGrey]]

--------------------------------------------------------------------------------
-- custom highlights

-- leading spaces
cmd[[highlight WhiteSpaceBol guibg=DarkGrey ctermbg=DarkGrey]]
cmd[[call matchadd('WhiteSpaceBol', '^ \+')]]

-- Annotations
cmd[[highlight def link myAnnotations Todo]] -- use same styling as "TODO"
cmd[[call matchadd('myAnnotations', 'INFO\|TODO\|NOTE') ]]

-- Underline URLs
cmd[[highlight urls cterm=underline gui=underline]]
cmd[[call matchadd('urls', 'http[s]\?:\/\/[[:alnum:]%\/_#.-]*') ]]

--------------------------------------------------------------------------------

-- GUTTER
cmd[[highlight clear SignColumn]] -- transparent

-- Git Gutter
g.gitgutter_map_keys = 0 -- disable gitgutter mappings I don't use anyway

cmd[[highlight GitGutterAdd    guifg=Green  ctermfg=Green]]
cmd[[highlight GitGutterChange guifg=Yellow ctermfg=Yellow]]
cmd[[highlight GitGutterDelete guifg=Red    ctermfg=Red]]
g.gitgutter_sign_added = '│'
g.gitgutter_sign_modified = '│'
g.gitgutter_sign_removed = '–'
g.gitgutter_sign_removed_first_line = '⎺'
g.gitgutter_sign_removed_above_and_below = '␥'
g.gitgutter_sign_modified_removed = '│'
g.gitgutter_sign_priority = 9 -- lower to not overwrite when in conflict with other icon

-- INFO: Coc Gutter indicators set in coc-settings.json

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

require('lualine').setup {
	sections = {
		lualine_a = {{ 'mode', fmt = function(str) return str:sub(1,1) end }},
		lualine_b = {{ currentFile }},
		lualine_c = {{ alternateFile }},
		lualine_x = {'diff'},
		lualine_y = {{'diagnostics', sources = { 'nvim_diagnostic', 'coc', 'ale' }}},
		lualine_z = {'location', 'progress'}
	},
	options = {
		theme  = 'auto',
		globalstatus = true,
		component_separators = { left = '', right = ''},
		section_separators = { left = '', right = ''},
	},
}

--------------------------------------------------------------------------------
-- WILDMENU

-- INFO: "UpdateRemotePlugins" may be necessary to make wilder work correctly
-- https://github.com/gelguy/wilder.nvim/issues/158

local wilder = require('wilder')
wilder.setup({modes = {':', '/', '?'}})
wilder.set_option('renderer', wilder.popupmenu_renderer(
	wilder.popupmenu_border_theme({
		highlighter = wilder.basic_highlighter(),
		min_width = '30%',
		min_height = '15%',
		max_height = '50%',
		left = {' ', wilder.popupmenu_devicons()},
		reverse = 0,
		border = 'rounded',
		highlights = {
			accent = wilder.make_hl('WilderAccent', 'Pmenu', {
				{foreground = 'Magenta'}, -- term
				{foreground = 'Magenta'}, -- cterm
				{foreground = '#f4468f'} -- gui
			}),
		},
	})
))



