-- netrw
g.netrw_list_hide= '.*\\.DS_Store$,^./$' -- hide files created by macOS & current directory
g.netrw_banner = 0 -- no ugly top banner

-- wildfire
-- https://github.com/gcmt/wildfire.vim#advanced-usage
g.wildfire_objects = {"iw", "iW", "i'", 'i"', "i)", "i]", "i}", "ii", "aI", "ip"}

-- Sneak
cmd[[let g:sneak#s_next = 1]] -- "s" repeats, like with clever-f
cmd[[let g:sneak#use_ic_scs = 1]] -- smart case
cmd[[let g:sneak#prompt = '👟']] -- the sneak in command line :P

-- Emmet: use only in CSS insert mode
g.user_emmet_install_global = 0
autocmd("FileType", {
	pattern = "css",
	command = "EmmetInstall"
})
g.user_emmet_mode='i'


-- find substring
-- cheat.sh
keymap("n", "<leader>k", [[:call cheat#cheat("", getcurpos()[1], getcurpos()[1], 0, 0, '!')<CR>]], {script = true, silent = true})
keymap("v", "<leader>k", [[:call cheat#cheat("", -1, -1, 2, 0, '!')<CR>]], {script = true, silent = true})

g.CheatSheetSilent = 0
g.CheatSheetDoNotMap = 1
g.CheatDoNotReplaceKeywordPrg = 1
g.CheatSheetReaderCmd = 'vsplit'

autocmd("BufEnter", {
	pattern = g.CheatSheetBufferName,
	callback = function ()
		bo.syntax="ON" -- needed cause treesitter turns syntax off
		keymap({"n", "v"}, "q", ":quit<CR>", {silent = true, buffer = true}) -- since it's effectively a read only mode
	end
})

-- find substring

