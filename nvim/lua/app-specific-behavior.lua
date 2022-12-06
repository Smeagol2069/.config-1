require("lua.utils")
require("lua.window-management")
require("lua.system-and-cron")
--------------------------------------------------------------------------------

-- TRANSPARENT background for Obsidian & Alacritty & Neovim
local function hideAllExcept(appNotToHide)
	local mainScreen = hs.screen.mainScreen()
	local wins = hs.window.orderedWindows() -- `orderedWindows()` ignores headless apps like Twitterrific
	for i = 1, #wins do
		local appli = wins[i]:application()
		if not (appli) then break end

		local winScreen = wins[i]:screen()

		local isPictureInPicture = false
		if appli:name() == "Brave Browser" or appli:name() == "YouTube" then -- if Browser has PiP window, do not hide it
			local browserWins = appli:allWindows()
			for j = 1, #browserWins do
				if browserWins[j]:title() == "Picture in Picture" then isPictureInPicture = true end
			end
		end

		if not (appli:name() == appNotToHide) and not (isPictureInPicture) and winScreen == mainScreen then -- main screen as condition for two-screen setups
			appli:hide()
		end
	end
end

-- not local, since needed by window movements
local function unHideAll()
	local wins = hs.window.allWindows() -- using `allWindows`, since `orderedWindows` only lists visible windows
	for i = 1, #wins do
		local appli = wins[i]:application()
		if not (appli) then break end
		if appli:isHidden() then appli:unhide() end
	end
end

local function transBackgroundApp(appName, eventType, appObject)
	if not (appName == "neovide" or appName == "Neovide" or appName == "Obsidian" or appName == "alacritty" or
		appName == "Alacritty") then return end

	local win = appObject:mainWindow()
	if (eventType == aw.activated or eventType == aw.launching) and (isPseudoMaximized(win) or isMaximized(win)) then
		hideAllExcept(appName)
	elseif eventType == aw.terminated then
		unHideAll()
	end
end

transBgAppWatcher = aw.new(transBackgroundApp)
transBgAppWatcher:start()

--------------------------------------------------------------------------------

-- PIXELMATOR
pixelmatorWatcher = aw.new(function(appName, eventType)
	if appName:find("Pixelmator") and eventType == aw.launched then
		runWithDelays(0.3, function() moveResizeCurWin("maximized") end)
	end
end)
pixelmatorWatcher:start()

--------------------------------------------------------------------------------

-- BRAVE BROWSER
-- split when second window is opened
-- change sizing back, when back to one window
wf_browser = wf.new("Brave Browser")
	:setOverrideFilter {
		rejectTitles = {" %(Private%)$", "^Picture in Picture$", "^Task Manager$"},
		allowRoles = "AXStandardWindow",
		hasTitlebar = true
	}
	:subscribe(wf.windowCreated, function()
		if #wf_browser:getWindows() == 1 then
			if isAtOffice() or isProjector() then
				moveResizeCurWin("maximized")
			else
				moveResizeCurWin("pseudo-maximized")
			end
		elseif #wf_browser:getWindows() == 2 then
			local win1 = wf_browser:getWindows()[1]
			local win2 = wf_browser:getWindows()[2]
			moveResize(win1, hs.layout.left50)
			moveResize(win2, hs.layout.right50)
		end
	end)
	:subscribe(wf.windowDestroyed, function()
		if #wf_browser:getWindows() == 1 then
			local win = wf_browser:getWindows()[1]
			moveResize(win, baseLayout)
		end
	end)
	:subscribe(wf.windowTitleChanged, function(win)
		local hasSound = win:title():find("Audio playing")
		-- not working properly when the tab stays the same, but at least works
		-- with tab change. Since background tabs do have "audio playing" as
		-- title, there is no good trigger for starting again.
		if hasSound then spotifyTUI("pause") end
	end)

-- Automatically hide Browser has when no window
wf_browser_all = wf.new("Brave Browser")
	:setOverrideFilter {allowRoles = "AXStandardWindow"}
	:subscribe(wf.windowDestroyed, function()
		if #wf_browser_all:getWindows() == 0 then
			app("Brave Browser"):hide()
		end
	end)

-- if activated but no window, pass through (no accidental alt-tabbing into it)
local function browserPassThrough(appName, eventType, browserAppObj)
	if appName == "Brave Browser" and eventType == aw.activated then
		runWithDelays(0.1, function()
			local browserWins = #browserAppObj:allWindows()
			if browserWins == 0 then browserAppObj:hide() end
		end)
	end
end

browserWatcher = aw.new(browserPassThrough)
browserWatcher:start()

--------------------------------------------------------------------------------

-- MIMESTREAM
-- split when second window is opened
-- change sizing back, when back to one window
wf_mimestream = wf.new("Mimestream")
	:setOverrideFilter {
		allowRoles = "AXStandardWindow",
		rejectTitles = {"General", "Accounts", "Sidebar & List", "Viewing", "Composing", "Templates", "Signatures", "Labs",
			"Updating Mimestream", "Software Update"}
	}
	:subscribe(wf.windowCreated, function(newWindow)
		if #wf_mimestream:getWindows() == 2 then
			local win1 = wf_mimestream:getWindows()[1]
			local win2 = wf_mimestream:getWindows()[2]
			moveResize(win1, hs.layout.left50)
			moveResize(win2, hs.layout.right50)
		elseif #wf_mimestream:getWindows() == 1 then
			moveResize(newWindow, pseudoMaximized)
		end
	end)
	:subscribe(wf.windowDestroyed, function()
		if #wf_mimestream:getWindows() == 1 then
			local win = wf_mimestream:getWindows()[1]
			moveResize(win, baseLayout)
		end
	end)
	:subscribe(wf.windowFocused, function()
		app("Mimestream"):selectMenuItem {"Window", "Bring All to Front"}
	end)

--------------------------------------------------------------------------------

-- keep TWITTERRIFIC visible, when active window is pseudomaximized
local function twitterrificNextToPseudoMax(_, eventType)
	if appIsRunning("Twitterrific") and (eventType == aw.activated or eventType == aw.launching) then
		local currentWin = hs.window.focusedWindow()
		if isPseudoMaximized(currentWin) then
			app("Twitterrific"):mainWindow():raise()
		end
	end
end

anyAppActivationWatcher = aw.new(twitterrificNextToPseudoMax)
anyAppActivationWatcher:start()

--------------------------------------------------------------------------------

-- NEOVIM
-- pseudomaximized window & killing leftover neovide process
wf_neovim = wf.new {"neovide", "Neovide"}
	:subscribe(wf.windowCreated, function()
		runWithDelays({0.2, 0.4, 0.6, 0.8}, function()
			if isAtOffice() or isProjector() then
				moveResizeCurWin("maximized")
			else
				moveResizeCurWin("pseudo-maximized")
			end
		end)
	end)
	-- bugfix for: https://github.com/neovide/neovide/issues/1595
	:subscribe(wf.windowDestroyed, function()
		if #wf_neovim:getWindows() == 0 then
			runWithDelays(3, function() hs.execute("pgrep neovide || pkill nvim") end)
		end
	end)

--------------------------------------------------------------------------------

-- ALACRITTY
-- pseudomaximized window
wf_alacritty = wf.new {"alacritty", "Alacritty"}
	:setOverrideFilter {rejectTitles = {"^cheatsheet: "}}
	:subscribe(wf.windowCreated, function()
		if isAtOffice() or isProjector() then
			moveResizeCurWin("maximized")
		else
			moveResizeCurWin("pseudo-maximized")
		end
	end)

-- ALACRITTY Man / cheat sheet leaader hotkey (for Karabiner)
-- work around necessary, cause alacritty creates multiple instances, i.e.
-- multiple applications all with the name "alacritty", preventing conventional
-- methods for focussing a window via AppleScript
uriScheme("focus-help", function()
	local win = hs.window.find("man:")
	if not (win) then win = hs.window.find("builtin:") end
	if not (win) then win = hs.window.find("cheatsheet:") end

	if win then
		win:focus()
	else
		notify("None open.")
	end
end)

--------------------------------------------------------------------------------

-- FINDER
wf_finder = wf.new("Finder")
	:setOverrideFilter {
		rejectTitles = {"Move", "Delete", "Copy", "Finder Settings", " Info$"},
		allowRoles = "AXStandardWindow",
		hasTitlebar = true
	}
	:subscribe(wf.windowDestroyed, function()
		if #wf_finder:getWindows() == 0 then
			-- INFO: quitting Finder requires `defaults write com.apple.finder QuitMenuItem -bool true`
			app("Finder"):kill()
		elseif #wf_finder:getWindows() == 1 then
			moveResizeCurWin("centered")
		end
	end)
	:subscribe(wf.windowCreated, function(newWin)
		if newWin:title() == "RomComs" then
			moveResizeCurWin("maximized")
		elseif #wf_finder:getWindows() == 1 then
			moveResizeCurWin("centered")
		elseif #wf_finder:getWindows() == 2 then
			local win1 = wf_finder:getWindows()[1]
			local win2 = wf_finder:getWindows()[2]
			moveResize(win1, hs.layout.left50)
			moveResize(win2, hs.layout.right50)
		end

		app("Finder"):selectMenuItem {"View", "Hide Sidebar"}
		app("Finder"):selectMenuItem {"Window", "Bring All to Front"}
	end)

-- quit Finder if it was started as a helper (e.g., JXA), but has no window
local function finderWatcher(appName, eventType, finderAppObj)
	if appName == "Finder" and eventType == aw.launched then
		runWithDelays({1, 4, 7, 10}, function()
			if finderAppObj and not (finderAppObj:mainWindow()) then
				finderAppObj:kill()
			end
		end)
	end
end

finderAppWatcher = aw.new(finderWatcher)
finderAppWatcher:start()

--------------------------------------------------------------------------------

-- ZOOM
-- close first window, when second is open
-- don't leave tab behind when opening zoom
wf_zoom = wf.new("zoom.us")
	:subscribe(wf.windowCreated, function()
		applescript [[
			tell application "Brave Browser"
				set window_list to every window
				repeat with the_window in window_list
					set tab_list to every tab in the_window
					repeat with the_tab in tab_list
						set the_url to the url of the_tab
						if the_url contains ("zoom.us") then close the_tab
					end repeat
				end repeat
			end tell
		]]
		local numberOfZoomWindows = #wf_zoom:getWindows();
		if numberOfZoomWindows == 2 then
			runWithDelays({1, 2}, function()
				app("zoom.us"):findWindow("^Zoom$"):close()
			end)
		end
	end)

--------------------------------------------------------------------------------

-- HIGHLIGHTS
-- - Sync Dark & Light Mode
-- - Start with Highlight as Selection
local function highlightsWatcher(appName, eventType, appObject)
	if not (eventType == aw.launched and appName == "Highlights") then return end

	local targetView = "Default"
	if isDarkMode() then targetView = "Night" end
	appObject:selectMenuItem {"View", "PDF Appearance", targetView}

	-- pre-select yellow highlight tool & hide toolbar
	appObject:selectMenuItem {"Tools", "Highlight"}
	appObject:selectMenuItem {"Tools", "Color", "Yellow"}
	appObject:selectMenuItem {"View", "Hide Toolbar"}

	if isAtOffice() then
		moveResizeCurWin("maximized")
	else
		moveResizeCurWin("pseudo-maximized")
	end
end

highlightsAppWatcher = aw.new(highlightsWatcher)
highlightsAppWatcher:start()

--------------------------------------------------------------------------------

-- DRAFTS: Hide Toolbar & set proper workspace

draftsWatcher = aw.new(function (appName, eventType, appObject)
	if not (appName == "Drafts") then return end

	if eventType == aw.launched or eventType == aw.activated then
		local workspace = isAtOffice() and "Office" or "Home"
		runWithDelays(0.2, function()
			local name = appObject:focusedWindow():title()
			local isTaskList = name:find("Supermarkt$") or name:find("Drogerie$") or name:find("Ernährung$")
			if not (isTaskList) then
				appObject:selectMenuItem {"Workspaces", workspace}
			end
			appObject:selectMenuItem {"View", "Hide Toolbar"}
		end)
	end
end)
draftsWatcher:start()

--------------------------------------------------------------------------------

-- SPOTIFY
-- Pause Spotify on launch
-- Resume Spotify on quit
function spotifyTUI(toStatus) -- has to be non-local function
	local currentStatus = hs.execute("export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ; spt playback --status --format=%s")
	currentStatus = trim(currentStatus) ---@diagnostic disable-line: param-type-mismatch
	if (currentStatus == "▶️" and toStatus == "pause") or (currentStatus == "⏸" and toStatus == "play") then
		local stdout = hs.execute("export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ; spt playback --toggle")
		if toStatus == "play" then notify(stdout) end ---@diagnostic disable-line: param-type-mismatch
	end
end

local function spotifyToggler(appName, eventType)
	if appName == "YouTube" or appName == "zoom.us" or appName == "FaceTime" then
		if eventType == aw.launched then
			spotifyTUI("pause")
		elseif eventType == aw.terminated and not (isProjector()) then
			spotifyTUI("play")
		end
	end
end

spotifyAppWatcher = aw.new(spotifyToggler)
if not (isAtOffice()) then spotifyAppWatcher:start() end

--------------------------------------------------------------------------------
-- SCRIPT EDITOR
wf_script_editor = wf.new("Script Editor")
	:subscribe(wf.windowCreated, function(newWindow)
		if newWindow:title() == "Open" then
			keystroke({"cmd"}, "n")
			runWithDelays(0.2, function()
				keystroke({"cmd"}, "v")
				moveResizeCurWin("centered")
			end)
			runWithDelays(0.4, function()
				keystroke({"cmd"}, "k")
			end)
		end
	end)

--------------------------------------------------------------------------------

-- DISCORD
local function discordWatcher(appName, eventType)
	if appName ~= "Discord" then return end

	-- on launch, open OMG Server instead of friends (who needs friends if you have Obsidian?)
	if eventType == aw.launched then
		openLinkInBackground("discord://discord.com/channels/686053708261228577/700466324840775831")
	end

	-- when focused, enclose URL in clipboard with <>
	-- when unfocused, removes <> from URL in clipboard
	local clipb = hs.pasteboard.getContents()
	if not (clipb) then return end

	if eventType == aw.activated then
		local hasURL = clipb:match("^https?:%S+$")
		local hasObsidianURL = clipb:match("^obsidian:%S+$")
		local isTweet = clipb:match("^https?://twitter%.com") -- for tweets, the previews are actually useful
		if (hasURL or hasObsidianURL) and not (isTweet) then
			hs.pasteboard.setContents("<" .. clipb .. ">")
		end
	elseif eventType == aw.deactivated then
		local hasEnclosedURL = clipb:match("^<https?:%S+>$")
		local hasEnclosedObsidianURL = clipb:match("^<obsidian:%S+>$")
		if hasEnclosedURL or hasEnclosedObsidianURL then
			clipb = clipb:sub(2, -2) -- remove first & last character
			hs.pasteboard.setContents(clipb)
		end
	end
end

discordAppWatcher = aw.new(discordWatcher)
discordAppWatcher:start()

--------------------------------------------------------------------------------

-- SHOTTR
-- Auto-select Arrow
wf_shottr = wf.new("Shottr")
	:subscribe(wf.windowCreated, function(newWindow)
		if newWindow:title() == "Preferences" then return end
		runWithDelays(0.1, function()
			keystroke({}, "a")
		end)
	end)

--------------------------------------------------------------------------------

-- WARP
-- since window size saving & session saving is not separated
warpWatcher = aw.new(function(appName, eventType)
	if appName == "Warp" and eventType == aw.launched then
		keystroke({"cmd"}, "k") -- clear
	end
end)
warpWatcher:start()