# shellcheck disable=SC1091,SC1090

printf '\33c\e[3J' # remove last login message https://stackoverflow.com/a/69915614

CONFIG=()
CONFIG+=('load_plugins')
CONFIG+=('terminal_utils')
CONFIG+=('aliases')
CONFIG+=('history_config')
CONFIG+=('general_and_plugin_configs')
CONFIG+=('completions')
CONFIG+=('keybindings')
[[ $TERM != "xterm-256color" ]] && CONFIG+=('vi-mode')
CONFIG+=('docs_man')
CONFIG+=('git_github')
CONFIG+=('homebrew')
CONFIG+=('alacritty_theme_utilities')
CONFIG+=('../pandoc/pandoc')
CONFIG+=('intro-messages')

for config_file in "${CONFIG[@]}"; do
	source "$DOTFILE_FOLDER/zsh/$config_file.zsh"
done


