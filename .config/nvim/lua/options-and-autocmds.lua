-- Default vim settings: https://neovim.io/doc/user/vim_diff.html
require("utils")
-------------------------------------------------------------------------------

-- Search
opt.showmatch = true
opt.smartcase = true
opt.ignorecase = true

-- Popup
opt.pumheight = 15 -- max number of items in popup menu
opt.pumwidth = 10 -- min width popup menu

-- Spelling
opt.spell = false
opt.spelllang = "en_us,de_de"

-- Gutter
opt.fillchars = 'eob: ' -- hide the ugly "~" marking the end of the buffer
opt.numberwidth = 3 -- minimum width, save some space for shorter files
opt.number = false
opt.relativenumber = false

-- whitespace & indentation
opt.tabstop = 3
opt.softtabstop = 3
opt.shiftwidth = 3
opt.shiftround = true
opt.list = true
opt.listchars = "multispace:··,tab:  "

-- remove trailing whitespaces on save
augroup("Mini-Lint",{})
autocmd("BufWritePre", {
	group = "Mini-Lint",
	callback = function ()
		local save_view = fn.winsaveview() -- save cursor positon
		cmd[[%s/\s\+$//e]]
		fn.winrestview(save_view)
	end
})

-- Split
opt.splitright = true -- vsplit right instead of left
opt.splitbelow = true -- split down instead of up

-- Command line
opt.history = 777 -- do not save too much history to reduce noise for command line history search

-- Mouse
opt.mousemodel="extend" -- deacvitate context menu, right mouse instead expands selection

-- Window Managers/espanso: set title
opt.title = true
opt.titlelen = 0 -- do not shorten title
opt.titlestring='%{expand(\"%:p\")} [%{mode()}]'

-- width
opt.textwidth = 80 -- used by `gq` and wrap
opt.wrap = false
opt.colorcolumn = "+1"

-- files
opt.hidden = true -- inactive buffers are only hidden, not unloaded
opt.undofile = true -- persistent undo history
opt.confirm = true -- unsaved bufers trigger confirmation prompt instead of failing
opt.autochdir = true -- always current directory
autocmd({"BufWinEnter"}, { -- since autochdir is not always reliable...?
	command = "cd %:p:h"
})

-- auto-save
autocmd({"BufWinLeave", "BufLeave", "QuitPre", "FocusLost", "InsertLeave"}, {
	pattern = "?*",
	command = "silent! update"
})

-- editor
opt.cursorline = true
opt.scrolloff = 12
opt.sidescrolloff = 21

-- Formatting vim.opt.formatoptions:remove("o") would not work, since it's
-- overwritten by the ftplugins having the o option. therefore needs to be set
-- via autocommand https://www.reddit.com/r/neovim/comments/sqld76/stop_automatic_newline_continuation_of_comments/
autocmd("BufEnter", {
	---@diagnostic disable-next-line: assign-type-mismatch
	callback = function () opt.formatoptions = opt.formatoptions - {"o", "r"} end
})

-- Remember Cursor Position
autocmd ("BufReadPost", {
	command = [[if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit' |  exe "normal! g`\"" | endif]]
})

-- clear cmdline on entering buffer
autocmd ("BufReadPost", { command = "echo" })

-- clipboard & yanking
opt.clipboard = 'unnamedplus'
autocmd("TextYankPost", { command = "silent! lua vim.highlight.on_yank{timeout = 2500}" })

-- don't treat "-" as word boundary for kebab-case variables – https://superuser.com/a/244070
-- (see also the respective "change small word" keybinding <leader><space>)
opt.iskeyword = opt.iskeyword + {"-", "_"}

-- status bar
opt.showcmd = true -- keychords pressed
opt.showmode = false -- don't show "-- Insert --"
opt.laststatus = 3 -- show one status line for all splits

-- folding
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()" -- use treesitter for folding https://github.com/nvim-treesitter/nvim-treesitter
opt.foldenable = false -- do not fold on start
opt.foldminlines = 2
augroup("rememberFolds", {}) -- keep folds on save https://stackoverflow.com/questions/37552913/vim-how-to-keep-folds-on-save
autocmd("BufWinLeave", {
	pattern = "?*",
	group = "rememberFolds",
	command = "silent! mkview"
})
autocmd("BufWinEnter", {
	pattern = "?*",
	group = "rememberFolds",
	command = "silent! loadview"
})

-- Terminal Mode
augroup("Terminal", {})
autocmd("TermOpen", {
	group = "Terminal",
	pattern = "*",
	command = "startinsert"
})
autocmd("TermClose", {
	group = "Terminal",
	pattern = "*",
	command = "bd"
})

--------------------------------------------------------------------------------

-- Skeletons (Templates)
-- BufReadPost + empty file as additional condition to also auto-insert
-- skeletons created by other apps
augroup("Templates", {})
autocmd({"BufReadPost", "BufNewFile"}, {
	group = "Templates",
	pattern = "*",
	callback = function ()
		local filestypesWithSkeletons = {"lua", "sh", "applescript", "js"}
		local fileHasSkeleton = vim.tbl_contains(filestypesWithSkeletons, bo.filetype)
		local fileIsEmpty = fn.getfsize(fn.expand("%")) < 2
		if fileHasSkeleton and fileIsEmpty then
			cmd("0r ~/.config/nvim/templates/skeleton."..bo.filetype)
			cmd[[normal! G]]
		end
	end,
})
