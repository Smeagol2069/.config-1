#!/usr/bin/env zsh
# shellcheck disable=SC2034

#-------------------------------------------------------------------------------
# ESSENTIAL INSTALLS

# ask for credentials upfront
sudo -v

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install --no-quarantine macpass alfred hammerspoon sublime-text karabiner-elements brave-browser alacritty

#-------------------------------------------------------------------------------
# ESSENTIAL SETTINGS

# Sublime
echo '{"save_selections": false}' > ~"/dotfiles/Sublime User Folder/AutoFoldCode.sublime-settings"

# Hammerspoon
defaults write "org.hammerspoon.Hammerspoon" "MJShowMenuIconKey" 0


#-------------------------------------------------------------------------------
# GET DOTFILES

cd ~ || exit 1
git clone git@github.com:chrisgrieser/dotfiles.git

cd ~/dotfiles/Alfred.alfredpreferences/workflows/ || exit 1
git clone git@github.com:chrisgrieser/shimmering-obsidian.git
git clone git@github.com:chrisgrieser/alfred-bibtex-citation-picker.git
git clone git@github.com:chrisgrieser/pdf-annotation-extractor-alfred.git


#-------------------------------------------------------------------------------
# CREATE ALL SYMLINKS IN THE APPROPRIATE LOCATIONS

DOTFILE_FOLDER="$(dirname "$0")"

# zsh
[[ -e ~/.zshrc ]] && rm -rf ~/.zshrc
ln -sf "$DOTFILE_FOLDER/zsh/.zshrc" ~
[[ -e ~/.zprofile ]] && rm -rf ~/.zprofile
ln -sf "$DOTFILE_FOLDER/zsh/.zprofile" ~
ln -sf "$DOTFILE_FOLDER/zsh/.zlogin" ~

# other dotfiles
ln -sf "$DOTFILE_FOLDER/.searchlink" ~
ln -sf "$DOTFILE_FOLDER/.vimrc" ~
ln -sf "$DOTFILE_FOLDER/pandoc/" ~/.pandoc

# linter rcfiles
ln -sf "$DOTFILE_FOLDER/linter rcfiles/.stylelintrc.json" ~
ln -sf "$DOTFILE_FOLDER/linter rcfiles/.eslintrc.json" ~
ln -sf "$DOTFILE_FOLDER/linter rcfiles/.markdownlintrc" ~
ln -sf "$DOTFILE_FOLDER/linter rcfiles/.pylintrc" ~
ln -sf "$DOTFILE_FOLDER/linter rcfiles/.shellcheckrc" ~
ln -sf "$DOTFILE_FOLDER/linter rcfiles/.flake8" ~

# .config
[[ -e ~/.config ]] && rm -rf ~/.config
ln -sf "$DOTFILE_FOLDER/.config/" ~/.config

# Hammerspoon
[[ -e ~/.hammerspoon ]] && rm -rf ~/.hammerspoon
ln -sf "$DOTFILE_FOLDER/hammerspoon" ~/.hammerspoon

# Marta
ln -sf /Applications/Marta.app/Contents/Resources/launcher /opt/homebrew/bin/marta
MARTA_DIR=~"/Library/Application Support/org.yanex.marta"
if [[ -e "$MARTA_DIR" ]] ; then
	rm -rf "$MARTA_DIR"
else
	mkdir -p "$MARTA_DIR"
fi
ln -sf ~"/dotfiles/Marta" "$MARTA_DIR"

# Espanso
ESPANSO_DIR=~"/Library/Application Support/espanso"
if [[ -e "$ESPANSO_DIR" ]] ; then
	rm -rf "$ESPANSO_DIR"
else
	mkdir -p "$ESPANSO_DIR"
fi
ln -sf "$DOTFILE_FOLDER/espanso/" "$ESPANSO_DIR"

# Sublime
SUBLIME_USER_DIR=~"/Library/Application Support/Sublime Text/Packages/User"
SUBLIME_PACKAGES=~"/Library/Application Support/Sublime Text/Installed Packages"

if [[ -e "$SUBLIME_USER_DIR" ]] ; then
	rm -rf "$SUBLIME_USER_DIR"
else
	mkdir -p "$SUBLIME_USER_DIR"
fi
ln -sf "$DOTFILE_FOLDER/Sublime User Folder/" "$SUBLIME_USER_DIR"

[[ -e "$SUBLIME_PACKAGES/CSS3.sublime-package" ]] && rm -rf "$SUBLIME_PACKAGES/CSS3.sublime-package"
ln -sf "$DOTFILE_FOLDER/Sublime Packages/CSS3.sublime-package" "$SUBLIME_PACKAGES"

# Brave
BROWSER="Brave Browser"
if [[ -e ~"/Applications/$BROWSER Apps.localized" ]] ; then
	rm -rf ~"/Applications/$BROWSER Apps.localized"
else
	mkdir -p ~"/Applications/$BROWSER Apps.localized"
fi
ln -sf ~"/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/$BROWSER Apps.localized/" ~"/Applications/$BROWSER Apps.localized"

# Übersicht
[[ -e ~"/Library/Application Support/Übersicht/widgets/" ]] && rm -rf ~"/Library/Application Support/Übersicht/widgets/"
mkdir -p ~"/Library/Application Support/Übersicht/widgets"
ln -sf "$DOTFILE_FOLDER/ubersicht" ~"/Library/Application Support/Übersicht/widgets"

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

# INFO: already set up, no need to run again.
# Only left here for reference, or when dotfile folder location changes

# # to keep private stuff out of the dotfile repo
# ln -sf ~"/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/private dotfiles/hammerspoon-private.lua" "$DOTFILE_FOLDER/hammerspoon/private.lua"
# ln -sf ~"/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/private dotfiles/espanso-private.yml" "$DOTFILE_FOLDER/espanso/match/private.yml"
# ln -sf ~"/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/private dotfiles/spotify-tui-client.yml" "$DOTFILE_FOLDER/.config/spotify-tui/client.yml"
# ln -sf ~"/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/private dotfiles/spotify_token_cache.json" "$DOTFILE_FOLDER/.config/spotify-tui/.spotify_token_cache.json"

# Obsidian vimrc
# OBSI_ICLOUD=~'/Library/Mobile Documents/iCloud~md~obsidian/Documents/'
# ln -sf "$DOTFILE_FOLDER/Obsidian vim/obsidian.vimrc" "$OBSI_ICLOUD/Main Vault/Meta"
# ln -sf "$DOTFILE_FOLDER/Obsidian vim/obsidian-vim-helpers.js" "$OBSI_ICLOUD/Main Vault/Meta"
# ln -sf "$DOTFILE_FOLDER/Obsidian vim/obsidian.vimrc" "$OBSI_ICLOUD/Development/Meta"
# ln -sf "$DOTFILE_FOLDER/Obsidian vim/obsidian-vim-helpers.js" "$OBSI_ICLOUD/Development/Meta"
# ln -sf "$DOTFILE_FOLDER/pandoc/README.md" "$OBSI_ICLOUD/Main Vault/Knowledge Base/Pandoc.md"

# YAMLlint
# ln -sf "$DOTFILE_FOLDER/.config/yamllint/config/.yamllint.yaml" "$DOTFILE_FOLDER/.config/karabiner/assets/complex_modifications"
# ln -sf "$DOTFILE_FOLDER/.config/yamllint/config/.yamllint.yaml" "$DOTFILE_FOLDER/espanso/config/"
# ln -sf "$DOTFILE_FOLDER/.config/yamllint/config/.yamllint.yaml" "$DOTFILE_FOLDER/espanso/match/"
