require("lua.utils")
--------------------------------------------------------------------------------
-- settings
hs.allowAppleScript(false)
hs.consoleOnTop(true)
hs.autoLaunch(true)
hs.automaticallyCheckForUpdates(true)
hs.window.animationDuration = 0

hs.loadSpoon('EmmyLua') -- runs lazy, i.e. only updates when there have been changes
--------------------------------------------------------------------------------

-- `hammerspoon://hs-reload` for reloading via Sublime Build System
hs.urlevent.bind("hs-reload", function()
	if SPLIT_RIGHT then vsplit("unsplit") end ---@diagnostic disable-line: undefined-global
	if hs.console.hswindow() then hs.console.hswindow():close() end -- close console
	hs.execute("touch ./is-reloading")
	hs.reload()
	hs.application("Hammerspoon"):hide() -- so the previous app does not loose focus
end)

--------------------------------------------------------------------------------
-- CONSOLE

hs.console.titleVisibility("hidden")
hs.console.toolbar(nil)

hs.console.consoleFont({name = "JetBrainsMonoNL Nerd Font", size = 18})

hs.console.darkMode(false)
hs.console.outputBackgroundColor{ white = 0.92 }

-- copy last command to clipboard
-- `hammerspoon://copy-last-command` for Karabiner Elements (⌘⇧C)
hs.urlevent.bind("copy-last-command", function()
	consoleHistory = hs.console.getHistory()
	lastcommand = consoleHistory[#consoleHistory]
	lastcommand = trim(lastcommand)
	hs.pasteboard.setContents(lastcommand)
	notify("Copied: '"..lastcommand.."'")
end)

-- `hammerspoon://clear-console` for Karabiner Elements (⌘K)
hs.urlevent.bind("clear-console", function()
	hs.console.clearConsole()
	-- no hiding needed, since Hammerspoon already frontmost
end)