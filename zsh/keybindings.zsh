# shellcheck disable=SC2086,SC2164

function bindEverywhere () {
	bindkey -M emacs "$1" $2
	bindkey -M viins "$1" $2
	bindkey -M vicmd "$1" $2
}
bindEverywhere "^A" beginning-of-line
bindEverywhere "^E" end-of-line
bindEverywhere "^K" kill-line
bindEverywhere "^Z" undo
bindEverywhere "^U" kill-whole-line
bindEverywhere "^P" copy-location
bindEverywhere "^B" copy-buffer
bindEverywhere "^L" open-location
bindEverywhere "^V" yank # (the emacs-yank which can be used to re-paste a line killed)
bindEverywhere '“' quote-all-args # “=alt+2
bindEverywhere '…' insert-last-word # …=alt+.

# [f]orward to editor
autoload edit-command-line
zle -N edit-command-line
bindEverywhere '^F' edit-command-line

# zsh-autosuggest
bindkey -M viins '^[[32;5~' autosuggest-execute # ctrl+esc (with esc remapped to f18)

# shift+tab: Cycle through base directories
bindEverywhere "^[[Z" dir-cycler

# [alt+arrow] - move word forward or backward (like on Mac)
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word


#-------------------------------------------------------------------------------
# INFO: use ctrl-v and then a key combination to get the shell binding
# `bindkey -M main` to show existing keybinds
# some bindings with '^' are reserved (^M=enter, ^I=tab, ^[[Z = shift+tab)
#-------------------------------------------------------------------------------

copy-location () {
	pwd | pbcopy
	zle -M "'$PWD' copied."
}
zle -N copy-location

alias l="open-location" # alias since `bindkey` not supported in Warp

open-location () {
	open .
}
zle -N open-location

# https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/copybuffer/copybuffer.plugin.zsh
copy-buffer () {
	printf "%s" "$BUFFER" | pbcopy
	zle -M "Buffer copied."
}
zle -N copy-buffer

quote-all-args() {
	if [[ "$BUFFER" =~ " " ]] ; then
		BUFFER="$(echo "$BUFFER" | sed 's/ / "/' | sed 's/$/"/' )"
	else
		BUFFER="\"$BUFFER\""
	fi
}
zle -N quote-all-args

function dir-cycler () {
	if [[ "$PWD" == "$WD" ]]; then
		echo
		z "$DOTFILE_FOLDER"
	elif [[ "$PWD" == "$DOTFILE_FOLDER" ]]; then
		echo
		z "$VAULT_PATH"
	else
		echo
		z "$WD"
	fi
	zle reset-prompt
}
zle -N dir-cycler
