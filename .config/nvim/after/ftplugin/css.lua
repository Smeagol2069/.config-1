require("utils")
--------------------------------------------------------------------------------

-- comment marks more useful than symbols for theme development
keymap("n", "gs", function() telescope.current_buffer_fuzzy_find{
	default_text='/* < ',
	prompt_prefix='🪧',
	prompt_title = 'Navigation Markers',
} end, {buffer = true, silent = true})

-- kebab-case variables, #hex color codes, & percentage values
cmd[[setlocal iskeyword+=#]] -- for whatever reason, appending to "bo.iskeyword" does not work...
cmd[[setlocal iskeyword+=%]]
cmd[[setlocal iskeyword+=-]]

-- INFO: fix syntax highlighting with ':syntax sync fromstart'
-- various other solutions are described here: https://github.com/vim/vim/issues/2790
-- however, using treesitter, this is less of an issue, but treesitter css
-- highlighting isn't good yet, so...
keymap("n", "zz", ":syntax sync fromstart<CR>", {buffer = true})
keymap("i", ",,", "<Plug>(emmet-expand-abbr)", {silent = true, buffer = true})


keymap("n", "<leader>v", '^Ellct;') -- change [v]alue key
keymap("n", "<leader>c", 'mzlEF.yEEp`z') -- double [c]lass under cursor
keymap("n", "<leader>C", 'lF.d/[.\\s]<CR>:nohl<CR>') -- delete class under cursor

-- toggle !important
keymap("n", "<leader>i", function ()
	local lineContent = fn.getline('.')
	if lineContent:find("!important") then
		lineContent = lineContent:gsub(" !important", "")
	else
		lineContent = lineContent:gsub(";", " !important;")
	end
	fn.setline(".", lineContent)
	---@diagnostic enable: undefined-field, param-type-mismatch
end, {buffer = true})

