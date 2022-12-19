require("config/utils")
--------------------------------------------------------------------------------
bo.path = ".,,../" -- also search parent directory (useful for Alfred)

keymap(
	{ "o", "x" },
	"aR",
	function() require("various-textobjs").jsRegex(false) end,
	{ desc = "inner regex textobj" }
)
keymap(
	{ "o", "x" },
	"iR",
	function() require("various-textobjs").jsRegex(true) end,
	{ desc = "inner regex textobj" }
)

require("regexplainer").setup {
	auto = true, -- automatically show the explainer when the cursor enters a regexp
	mappings = { toggle = nil },
	popup = {
		border = { style = borderStyle },
	},
}
