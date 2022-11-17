#!/bin/zsh
# INFO: on every change of the Neovim.app, it needs to be granted Accessibility
# permissions again to be able to send keystrokes

#───────────────────────────────────────────────────────────────────────────────
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

# workaround for: https://github.com/neovide/neovide/issues/1586
if pgrep "neovide" ; then
	prevClipb=$(pbpaste)

	[[ -n "$LINE" ]] && LINE="+$LINE"
	vimcmd="e $LINE $1"
	echo "$vimcmd" | pbcopy

	# wrangling around clipboard instead of keystrokeing path, since iCloud paths
	# with "~" result in diacretics like `õ`, making the path invalid
	osascript -e 'tell application "Neovide" to activate
		delay 0.07
		tell application "System Events"
			key code 53
			keystroke ":"
			delay 0.05
			keystroke "v" using command down
			delay 0.05
			keystroke return
		end tell'

	echo "$prevClipb" | pbcopy

# workaround for: https://github.com/neovide/neovide/issues/1604
else
	if [[ -z "$LINE" ]] ; then # $LINE is set via `open --env=LINE=num`
		neovide "$1"
	else
		neovide "+$LINE" "$1"
	fi
fi