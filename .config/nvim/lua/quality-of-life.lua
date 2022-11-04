---@diagnostic disable: param-type-mismatch, undefined-field
local getline = vim.fn.getline
local setline = vim.fn.setline
local lineNo = vim.fn.line
local append = vim.fn.append
local bo = vim.bo
local getCursor = vim.api.nvim_win_get_cursor
local setCursor = vim.api.nvim_win_set_cursor
local function wordUnderCursor() return vim.fn.expand("<cword>") end

local ret = {}

--------------------------------------------------------------------------------

function ret.duplicateLine()
	local line = getline(".")
	append(".", line)
	local lineNum = getCursor(0)[1] + 1 -- line down
	local colNum = getCursor(0)[2]
	setCursor(0, {lineNum, colNum})
end

function ret.duplicateVisual()
	local prevReg = vim.fn.getreg("z")
	cmd [[silent! normal!"zy`]"zp]]
	vim.fn.setreg("z", prevReg)
end

-- Duplicate line under cursor, and change occurences of certain words to their 
-- opposite, e.g., "right" to "left". Indended for languages like CSS.
function ret.smartDuplicateLine()
	local line = getline(".")
	if line:find("top") then
		line = line:gsub("top", "bottom")
	elseif line:find("bottom") then
		line = line:gsub("bottom", "top")
	elseif line:find("right") then
		line = line:gsub("right", "left")
	elseif line:find("left") then
		line = line:gsub("left", "right")
	elseif line:find("height") and not (line:find("line-height")) then
		line = line:gsub("height", "width")
	elseif line:find("width") and not (line:find("border-width")) and not (line:find("outline-width")) then
		line = line:gsub("width", "height")
	end
	append(".", line)

	-- cursor movement
	local lineNum = getCursor(0)[1] + 1 -- line down
	local colNum = getCursor(0)[2]
	local _, valuePos = line:find(": ?")
	if valuePos then -- if line was changed, move cursor to value of the property
		colNum = valuePos
	end
	setCursor(0, {lineNum, colNum})
end

-- insert horizontal divider considering textwidth, commentstring, and indent
---@param linechar? string Character used for horizontal divider. Default: "─"
function ret.hr(linechar)
	local indent = vim.fn.indent(".")
	local textwidth = bo.textwidth
	local comstr = bo.commentstring
	local comStrLength = #comstr:gsub("%%s", ""):gsub(" ", "")

	if not (linechar) then
		if comstr:find("-") then
			linechar = "-"
		else
			linechar = "─"
		end
	elseif #linechar > 1 then
		linechar:sub(1, 1)
	end

	local linelength = textwidth - indent - comStrLength
	local fullLine = string.rep(linechar, linelength)
	local hr = comstr:gsub(" ?%%s ?", fullLine)

	append(".", {hr, ""})
	cmd [[normal! j==]] -- move down and indent

	-- fix for blank lines inside indented blocks
	local line = getline(".")
	if bo.expandtab then
		line = line:sub(1, textwidth)
	else
		local spacesPerTab = string.rep(" ", bo.tabstop)
		line = line
			:gsub("\t", spacesPerTab)
			:sub(1, textwidth)
			:gsub(spacesPerTab, "\t")
	end
	setline(".", line)

end

-- Drop-in replacement for vim's `~` command. If the word under cursor has a
-- reasonable opposite in the current language (e.g., "top" and "bottom" in
-- css), then the word will be toggled. 
-- Otherwise will check character under cursor. If it is a "reversible"
-- character, the character will be switched, e.g. "(" to ")". If it is a
-- letter, falls back to the default `~` behavior of toggling between upper and
-- lower case.
function ret.switcher()
	-- ignore 'iskeyword' option when retrieving word under cursor
	local word
	local wordchar = bo.iskeyword
	dashIsKeyword = wordchar:find(",%-$") or wordchar:find(",%-,") or wordchar:find("^%-,")
	if dashIsKeyword then
		bo.iskeyword = wordchar:gsub("%-,?", ""):gsub(",?%-", "")
		word = wordUnderCursor()
		bo.iskeyword = wordchar
	else
		word = wordUnderCursor()
	end

	local col = getCursor(0)[2] + 1
	local char = getline("."):sub(col, col) ---@diagnostic disable-line: param-type-mismatch, undefined-field

	-- toggle words
	local opposite = ""
	if word == "true" then opposite = "false"
	elseif word == "false" then opposite = "true"
	end

	if bo.filetype == "css" then
		if word == "top" then opposite = "bottom"
		elseif word == "bottom" then opposite = "top"
		elseif word == "left" then opposite = "right"
		elseif word == "right" then opposite = "left"
		elseif word == "width" then opposite = "height"
		elseif word == "height" then opposite = "width"
		elseif word == "absolute" then opposite = "relative"
		elseif word == "relative" then opposite = "absolute"
		end
	elseif bo.filetype == "lua" then
		if word == "and" then opposite = "or"
		elseif word == "or" then opposite = "and"
		end
	elseif bo.filetype == "python" then
		if word == "True" then opposite = "False"
		elseif word == "False" then opposite = "True"
		end
	elseif bo.filetype == "javascript" or bo.filetype == "typescript" then
		if word == "const" then opposite = "let"
		elseif word == "let" then opposite = "const"
		end
	end

	if opposite ~= "" then
		cmd('normal! "_ciw' .. opposite)
		return
	end

	-- toggle case (regular ~)
	local isLetter = char:upper() ~= char:lower()
	if isLetter then
		cmd [[normal! ~]]
		return
	end

	-- switch punctuation
	local switched = ""
	if char == "<" then switched = ">"
	elseif char == ">" then switched = "<"
	elseif char == "(" then switched = ")"
	elseif char == ")" then switched = "("
	elseif char == "]" then switched = "["
	elseif char == "[" then switched = "]"
	elseif char == "{" then switched = "}"
	elseif char == "}" then switched = "{"
	elseif char == "/" then switched = "\\"
	elseif char == "\\" then switched = "/"
	elseif char == "'" then switched = '"'
	elseif char == '"' then switched = "'"
	elseif char == "," then switched = ";"
	elseif char == ";" then switched = ","
	end
	if switched ~= "" then
		cmd("normal! r" .. switched)
		return
	end
	print("Nothing under the cursor that can be switched")
end

function ret.overscroll(action) ---@param action string The motion to be executed when not at EOF
	local curLine = lineNo(".")
	local lastLine = lineNo("$")
	if (lastLine - curLine - 1) < vim.wo.scrolloff then
		cmd [[normal! zz]]
	end
	cmd("normal! " .. action)
end

-- log statement for variable under cursor, similar to the 'turbo console log'
-- popular VS Code plugin
-- supported: lua, js/ts, zsh/bash/fish, and applescript
---@param addLineNumber? boolean Whether to add the line number. Default: false
function ret.quicklog(addLineNumber)
	local varname = wordUnderCursor()
	local logStatement
	local ft = bo.filetype
	local lnStr = ""
	if addLineNumber then
		lnStr = "L" .. tostring(lineNo(".")) .. " "
	end

	if ft == "lua" then
		logStatement = 'print("' .. lnStr .. varname .. ': ", ' .. varname .. ")"
	elseif ft == "javascript" or ft == "typescript" then
		logStatement = 'console.log("' .. lnStr .. varname .. ': " + ' .. varname .. ")"
	elseif ft == "zsh" or ft == "bash" or ft == "fish" then
		logStatement = 'echo "' .. lnStr .. varname .. ": $" .. varname .. '"'
	elseif ft == "applescript" then
		logStatement = 'log "' .. lnStr .. varname .. ': " & ' .. varname
	else
		print("Quicklog does not support " .. ft .. " yet.")
	end

	append(".", logStatement)
	cmd [[normal! j==]] -- move down and indent
end

--------------------------------------------------------------------------------

return ret