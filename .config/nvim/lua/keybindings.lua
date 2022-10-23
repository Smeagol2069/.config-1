require("utils")
--------------------------------------------------------------------------------

require("utils")
--------------------------------------------------------------------------------
-- META
g.mapleader = ','

-- copy [l]ast ex[c]ommand
keymap("n", "<leader>lc", ':let @+=@:<CR>:echo "Copied:"@:<CR>')

-- run [l]ast command [a]gain
keymap("n", "<leader>la", ':<C-r>:<CR>')

-- search keymaps
keymap("n", "?", telescope.keymaps)
keymap("n", "<leader>?", telescope.help_tags)

-- Theme Picker
keymap("n", "<leader>T", telescope.colorscheme)

-- Highlights
keymap("n", "<leader>G", telescope.highlights)

-- Update [P]lugins
keymap("n", "<leader>p", function()
	cmd[[update! ~/.config/nvim/lua/plugin-list.lua]]
	package.loaded["plugin-list"] = nil -- empty the cache for lua
	require("plugin-list")
	local packer = require("packer")
	packer.startup(PluginList)
	packer.sync()
	cmd[[MasonUpdateAll]]
end)
keymap("n", "<leader>P", ":PackerStatus<CR>")

-- Utils
keymap("n", "ZZ", ":w<CR>:q<CR>") -- quicker quitting

--------------------------------------------------------------------------------
-- NAVIGATION

-- HJKL behaves like hjkl, but bigger distance (best used with scroll offset)
keymap("", "H", "0^") -- 0^ ensures scrolling to the left on long lines
keymap("", "L", "$")
keymap({"v", "o"}, "J", "7j")
keymap("", "K", "7k")

-- when reaching the last line, scroll down (since scrolloff does not work at EOF)
function overscroll (action) ---@param action string
	local curLine = fn.line(".")
	local lastLine = fn.line("$")
	if (lastLine - curLine - 1) < wo.scrolloff then
		cmd[[normal! zz]]
	end
	cmd("normal! "..action)
end
keymap("n", "j", function () overscroll("j") end)
keymap("n", "J", function () overscroll("7j") end)
keymap({"n", "v"}, "G", "Gzz")

-- Jump History
keymap("n", "<C-h>", "<C-o>") -- Back
keymap("n", "<C-l>", "<C-i>") -- Forward

-- Hunks
keymap("n", "gh", ":Gitsigns next_hunk<CR>")
keymap("n", "gH", ":Gitsigns next_prev<CR>")

-- Sneak
keymap("", "ö", "<Plug>Sneak_s")
keymap("", "Ö", "<Plug>Sneak_S")
keymap("", "f", "<Plug>Sneak_f")
keymap("", "F", "<Plug>Sneak_F")
keymap("", "t", "<Plug>Sneak_t")
keymap("", "T", "<Plug>Sneak_T")

-- Search
keymap("", "-", "/") -- German Keyboard consistent with US Keyboard layout
keymap("n", "/", "/\v") -- more PCRE-like regex patterns (:h magic)
keymap("n", "<Esc>", ":nohl<CR>:echo<CR>lh", {silent = true}) -- clear highlights & shortmessage, lh clears hover window
keymap("", "+", "*") -- no more modifier key on German Keyboard

-- URLs
keymap("n", "gü", "/http.*<CR>") -- goto next
keymap("n", "gÜ", "?http.*<CR>") -- goto prev

-- Marks
keymap("", "ä", "`") -- Goto Mark

--------------------------------------------------------------------------------
-- EDITING

-- CLIPBOARD
keymap({"n", "v"}, "x", '"_x')
keymap({"n", "v"}, "c", '"_c')
keymap({"n", "v"}, "C", '"_C')
keymap("n", "p", 'p`[') -- pasting does not move the cursor
keymap("n", "P", '"0p') -- paste what was yanked

-- TEXT OBJECTS
-- INFO: Various Text Objects are defined via treesitter textobj
-- the text-objects below need "_
keymap("n", "<Space>", '"_ciw') -- change word
keymap("n", "<C-A-Space>", '"_daw') -- wordaround, since <S-Space> not fully supported, requires karabiner remapping it
keymap("v", "<Space>", '"_c')

-- change small word (i.e. a simpler version of vim-textobj-variable-segment,
-- but not supporting CamelCase)
keymap("n", '<leader><Space>', function ()
	opt.iskeyword = opt.iskeyword - {"_", "-"}
	cmd[[normal! "_diw]]
	cmd[[startinsert]] -- :Normal does not allow to end in insert mode
	opt.iskeyword = opt.iskeyword - {"_", "-"}
end)

keymap("o", "iq", 'i"') -- double [q]uote
keymap("o", "aq", 'a"')
keymap("o", "iz", "i'") -- single quote (mnemonic: [z]itation)
keymap("o", "az", "a'")
keymap("o", "ir", "i]") -- [r]ectangular brackets
keymap("o", "ar", "a]")
keymap("o", "ic", "i}") -- [c]urly brackets
keymap("o", "ac", "a}")
keymap("o", "p", '}') -- rest of the [p]aragraph
keymap("o", "P", '{') -- beginning of the [P]aragraph

-- special plugin text objects
require("textobj-diagnostic").setup{create_default_keymaps = false}
keymap({"v", "o"}, "id", require("textobj-diagnostic").next_diag_inclusive, {silent = true})
keymap({"v", "o"}, "ad", require("textobj-diagnostic").next_diag_inclusive, {silent = true})
keymap({"v", "o"}, 'ih', ':Gitsigns select_hunk<CR>', {silent = true})
keymap({"v", "o"}, 'ah', ':Gitsigns select_hunk<CR>', {silent = true})

-- treesitter textobjects:
-- af -> a function
-- aC -> a condition
-- c -> comment
-- aa -> an argument

require("nvim-surround").setup{
	move_cursor = false,
	keymaps = {
		insert = "<C-g>s",
		visual = "s",
	},
	aliases = { -- aliases should match the bindings above
		["b"] = ")",
		["c"] = "}",
		["r"] = "]",
		["q"] = '"',
		["z"] = "'",
	},
}

-- COMMENTS (mnemonic: [q]uiet text)
require('Comment').setup{
	toggler = {
		line = 'qq',
		block = '<Nop>',
	},
	opleader = {
		line = 'q',
		block = '<Nop>',
	},
	extra = {
		above = 'qO',
		below = 'qo',
		eol = 'Q',
	},
}

-- effectively creating "q" as comment textobj, can't map directly to q since
-- overlap in visual mode where q can be object and operator. However, this
-- method here also has the advantage of making it possible to preserve cursor
-- position.
-- requires remap for treesitter and comments.nvim mappings
keymap("n", "dq", "mzdCOM`z", {remap = true})
keymap("n", "dq", "mzdCOM`z", {remap = true})
keymap("n", "yq", "mzyCOM`z", {remap = true})
keymap("n", "sq", "mzsCOM`z", {remap = true})
keymap("n", "cq", "mzdCOMxQ", {remap = true}) -- using delete to preserve commentstring

-- Whitespace Control
keymap("n", "!", "a <Esc>h")
keymap("n", "=", "mzO<Esc>`z") -- add blank above
keymap("n", "_", "mzo<Esc>`z") -- add blank below
keymap("n", "<BS>", function() -- reduce multiple blank lines to exactly one
	if fn.getline(".") == "" then ---@diagnostic disable-line: param-type-mismatch
		cmd[[normal! "_dipO]]
	else
		print("Line not empty.")
	end
end)

-- Indention
keymap("n", "<Tab>", ">>")
keymap("n", "<S-Tab>", "<<")
keymap("v", "<Tab>", ">gv")
keymap("v", "<S-Tab>", "<gv")

keymap({"n", "v"}, "^", "=") -- auto-indent
keymap("n", "^^", "mz=ip`z") -- since indenting paragraph is far more common than indenting a line
keymap("n", "^p", "mz`[v`]=`z") -- last paste
keymap("n", "^A", "mzgg=G`z") -- entire file

-- toggle word between Capital and lower case
keymap("n", "ü", "mzlblgueh~`z")

-- toggle case or switch direction of char (e.g. > to <)
keymap("n", "Ü", function ()
	-- toggle false/false
	local wordUnderCursor = fn.expand("<cword>")
	if wordUnderCursor == "true" then
		cmd[[normal! "_ciwfalse]]
		return
	elseif wordUnderCursor == "false" then
		cmd[[normal! "_ciwtrue]]
		return
	end

	-- toggle case
	local col = api.nvim_win_get_cursor(0)[2] + 1
	local char = fn.getline("."):sub(col, col) ---@diagnostic disable-line: param-type-mismatch, undefined-field
	local letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZäöüÄÖÜ"
	if letters:find(char) then
		cmd[[normal! ~h]]
		return
	end

	-- switch char
	local out = ""
	if char == "<" then out = ">"
	elseif char == ">" then out = "<"
	elseif char == "(" then out = ")"
	elseif char == ")" then out = "("
	elseif char == "]" then out = "["
	elseif char == "[" then out = "]"
	elseif char == "{" then out = "}"
	elseif char == "}" then out = "{"
	elseif char == "/" then out = "\\"
	elseif char == "\\" then out = "/"
	elseif char == "'" then out = '"'
	elseif char == '"' then out = "'"
	elseif char == "," then out = ";"
	elseif char == ";" then out = ","
	end
	if not(out) then return end
	cmd("normal! r"..out)
end)

-- <leader>{char} → Append {char} to end of line
local trailingKeys = {".", ",", ";", ":", '"', "'", "(", ")", "[", "]", "{", "}", "|", "/", "\\", "`" }
for i = 1, #trailingKeys do
	keymap("n", "<leader>"..trailingKeys[i], "mzA"..trailingKeys[i].."<Esc>`z")
end
-- Remove last character from line
keymap("n", "X", 'mz$"_x`z')

-- Spelling (mnemonic: [z]pelling)
keymap("n", "zl", telescope.spell_suggest)
keymap("n", "gz", "]s") -- next misspelling
keymap("n", "gZ", "[s") -- prev misspelling
keymap("n", "za", "1z=") -- Autocorrect word under cursor (= select 1st suggestion)

-- [S]ubstitute Operator (substitute.nvim)
local substi = require('substitute')
substi.setup()
keymap("n", "s", substi.operator)
keymap("n", "ss", substi.line)
keymap("n", "S", substi.eol)
keymap("x", "s", substi.visual)

-- Duplicate Line / Selection (mnemonic: [r]eplicate)
keymap("n", "R", ':noautocmd normal!mz"zyy"zp`zj<CR>', {silent = true}) -- current line, ":noautocmd" to disable highlighted yank for this
keymap("v", "R", '"zy`]"zp', {silent = true}) -- selection (best used with Visual Line Mode)

-- Line & Character Movement (vim.move plugin)
g.move_map_keys = 0 -- disable default keymaps of vim.move
keymap("n", "<Down>", "<Plug>MoveLineDown")
keymap("n", "<Up>", "<Plug>MoveLineUp")
keymap("v", "<Down>", "<Plug>MoveBlockDown")
keymap("v", "<Up>", "<Plug>MoveBlockUp")

keymap("n", "<Right>", "<Plug>MoveCharRight")
keymap("n", "<Left>", "<Plug>MoveCharLeft")
keymap("v", "<Right>", "<Plug>MoveBlockRight")
keymap("v", "<Left>", "<Plug>MoveBlockLeft")

-- Merging / Splitting Lines
keymap({"n", "v"}, "M", "J") -- [M]erge line up
keymap({"n", "v"}, "gm", "ddpkJ") -- [m]erge line down
g.splitjoin_split_mapping = '' -- disable default mappings
g.splitjoin_join_mapping = ''
keymap("n", "<leader>m", ":SplitjoinJoin<CR>")
keymap("n", "<leader>s", ":SplitjoinSplit<CR>")
keymap("n", "|", "a<CR><Esc>k$") -- Split line at cursor

-- Undo
keymap({"n", "v"}, "U", "<C-r>") -- redo
keymap("n", "<C-u>", "U") -- undo line
keymap("n", "<leader>u", ":UndotreeToggle<CR>") -- undo tree

--------------------------------------------------------------------------------
-- INSERT MODE & COMMAND MODE
keymap("i", "<C-e>", '<Esc>A') -- EoL
keymap("i", "<C-k>", '<Esc>lDi') -- kill line
keymap("i", "<C-a>", '<Esc>I') -- BoL
keymap("c", "<C-a>", '<Home>')
keymap("c", "<C-e>", '<End>')
keymap("c", "<C-u>", '<C-e><C-u>') -- clear

-- quicker typing
keymap("i", "!!", ' {}<Left><CR><Esc>O') -- {} with proper linebreak

--------------------------------------------------------------------------------
-- VISUAL MODE
keymap("v", "p", 'P') -- do not override register when pasting
keymap("v", "P", 'p') -- override register when pasting

keymap("n", "V", "Vj") -- visual line mode starts with two lines selected
keymap("v", "V", "j") -- repeatedly pressing "V" selects more lines

keymap("v", "y", "ygv<Esc>") -- yanking in visual mode keeps position https://stackoverflow.com/a/3806683#comment10788861_3806683

--------------------------------------------------------------------------------
-- WINDOW AND BUFFERS
keymap("", "<C-w>v", ":vsplit #<CR>") -- open the alternate file in the split instead of the current file
keymap("", "<C-w>h", ":split #<CR>")
keymap("", "<C-Right>", ":vertical resize +3<CR>") -- resizing on one key for sanity
keymap("", "<C-Left>", ":vertical resize -3<CR>")
keymap("", "<C-Down>", ":resize +3<CR>")
keymap("", "<C-Up>", ":resize -3<CR>")
keymap("n", "gw", "<C-w><C-w>") -- switch to next split

-- Buffers
keymap("", "<C-Tab>", "<C-^>") -- for footpedal
keymap({"n", "v"}, "gt", ":nohl<CR><C-^>", {silent = true}) -- switch to alt-file (use vim's buffer model instead of tabs)

--------------------------------------------------------------------------------
-- FILES

-- File switchers
keymap("n", "go", telescope.find_files) -- [o]pen file in parent-directory
keymap("n", "gO", function() telescope.find_files{cwd='%:p:h:h', prompt_prefix=' '} end) -- [o]pen file in grandparent-directory
keymap("n", "gr", telescope.oldfiles) -- [r]ecent files
keymap("n", "gb", telescope.buffers) -- open [b]uffer
keymap("n", "gf", telescope.live_grep) -- search in [f]iles

-- File Operations
keymap("n", "<C-p>", ':let @+ = expand("%:p")<CR>:echo "Copied:"expand("%:p")<CR>') -- copy path of current file
keymap("n", "<C-n>", ':let @+ = expand("%:t")<CR>:echo "Copied:"expand("%:t")<CR>') -- copy name of current file
keymap("n", "<C-r>", ':Rename ') -- rename of current file, requires eunuch.vim
keymap("n", "<C-d>", ':Duplicate <C-R>=expand("%:t")<CR>') -- duplicate current file
keymap("n", "<leader>X", ':Chmod +x<CR>') -- execution permission, requires eunuch.vim
keymap("n", "<leader><BS>", ':w!<CR>:!mv "%:p" ~/.Trash/<CR><CR>:bd<CR>:echo "file deleted"<CR>') -- undoable deletion of the file
keymap("v", "X", ":'<,'> w new.lua | normal gvd<CR>:buffer #<CR>:Rename ") -- refactor selection into new file

-- Option Toggling
keymap("n", "<leader>os", ":set spell!<CR>")
keymap("n", "<leader>or", ":set number! relativenumber!<CR>")
keymap("n", "<leader>ow", ":set wrap! <CR>")

--------------------------------------------------------------------------------

-- TERMINAL MODE
keymap("n", "zt", ":10split<CR>:terminal<CR>")
keymap("n", "zz", ":w<CR>:!acp ") -- shell function, enabled via .zshenv


--------------------------------------------------------------------------------

-- BUILD SYSTEM
keymap("n", "<leader>r", function()
	cmd[[write]]

	local filename = fn.expand("%:t") ---@diagnostic disable-line: missing-parameter
	if filename == "sketchybarrc" then
		-- fn.system("brew services restart sketchybar")

	elseif bo.filetype == "lua" then
		local parentFolder = fn.expand("%:p:h") ---@diagnostic disable-line: missing-parameter
		if not(parentFolder) then return end
		if parentFolder:find("nvim") then
			cmd[[write | source % | echo "Neovim config reloaded."]]
		else
			os.execute('open -g "hammerspoon://hs-reload"')
		end

	elseif bo.filetype == "yaml" then
		os.execute[[osascript -l JavaScript "$HOME/.config/karabiner/build-karabiner-config.js"]]

	elseif bo.filetype == "typescript" then
		cmd[[!npm run build]]

	elseif bo.filetype == "applescript" then
		cmd[[:AppleScriptRun]]
	else

		print("No build system set.")
	end
end)
--------------------------------------------------------------------------------

-- q to close special windows
autocmd("FileType", {
	pattern = specialFiletypes,
	callback = function ()
		keymap("n", "q", ":close<CR>", {buffer = true, silent = true, nowait = true})
	end
})

--------------------------------------------------------------------------------

-- [H]orizontal Ruler
keymap("n", "zh", function()
	---@diagnostic disable: param-type-mismatch
	if not(b.hrComment) then
		print("No hr for this filetype defined.")
		return
	end

	if bo.filetype == "css" then
		local hr = b.hrComment
		fn.append('.', hr)
		local lineNum = api.nvim_win_get_cursor(0)[1] + 2
		local colNum = #hr[2] + 2
		api.nvim_win_set_cursor(0, {lineNum, colNum})
		cmd[[startinsert]]
	else
		-- shorten hr by indent
		local indent = fn.indent(".")
		local hr = b.hrComment:sub(1, -(indent+1))
		fn.append('.', {hr, ""})
		cmd[[normal! j==]]
	end
	---@diagnostic enable: param-type-mismatch
end)

augroup("horizontalRuler", {})
autocmd( "FileType", {
	group = "horizontalRuler",
	pattern = {"json", "javascript", "typescript"},
	callback = function() b.hrComment = "//──────────────────────────────────────────────────────────────────────────────" end
})
autocmd( "FileType", {
	group = "horizontalRuler",
	pattern = {"bash", "zsh", "sh", "yaml"},
	callback = function() b.hrComment = "#───────────────────────────────────────────────────────────────────────────────" end
})
autocmd( "FileType", {
	group = "horizontalRuler",
	pattern = {"lua", "applescript"},
	callback = function() b.hrComment = "--------------------------------------------------------------------------------" end
})
autocmd( "FileType", {
	group = "horizontalRuler",
	pattern = {"markdown"},
	callback = function() b.hrComment = "---" end
})
autocmd( "FileType", {
	group = "horizontalRuler",
	pattern = {"css"},
	callback = function() b.hrComment = {
		"/* ───────────────────────────────────────────────── */",
		"/* << ",
		"──────────────────────────────────────────────────── */",
		"",
		"",
	} end,
})

