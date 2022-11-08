#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

const alfredMatcher = (str) => str.replace (/[-()_.]/g, " ") + " " + str + " ";
const getEnv = (path) => $.getenv(path).replace(/^~/, app.pathTo("home folder"));

const jsonArray = [];
const dotfileFolder = getEnv ("dotfile_folder");
/* eslint-disable no-multi-str, quotes */
const workArray = app.doShellScript (
	'PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH ;\
	cd "' + dotfileFolder + '" ; \
	fd --hidden --no-ignore \
	-E "Alfred.alfredpreferences" \
	-E ".config/alacritty/colors/*" \
	-E "Marta/Themes/*" \
	-E "packer_compiled.lua" \
	-E "hammerspoon/Spoons/*" \
	-E ".config/karabiner/automatic_backups/*" \
	-E ".config/karabiner/assets/complex_modifications/*.json" \
	-E "FileHistory*.json" \
	-E "visualized keyboard layout/*.json" \
	-E "Mac Migration Scripts/to do*" \
	-E "unused/*" \
	-E "Fonts/*" \
	-E ".config/coc/*" \
	-E ".DS_Store" \
	-E ".git/"'
).split("\r");
/* eslint-enable no-multi-str, quotes */

workArray.forEach(file => {
	const filePath = dotfileFolder + file.slice(1);
	const parts = file.split("/");
	const isFolder = file.endsWith("/");
	if (isFolder) parts.pop();
	const fileName = parts.pop();

	let twoParents = filePath.replace(/.*\/(.*\/.*)\/.*$/, "$1");
	if (twoParents === ".") twoParents = "";

	let ext = fileName.split(".").pop();
	if (ext.includes("rc")) ext = "rc"; // rc files
	else if (ext.startsWith("z")) ext = "zsh"; // zsh dotfiles

	let iconObject;
	switch (ext) {
		case "json":
			iconObject = { "path": "icons/json.png" };
			break;
		case "yaml":
		case "yml":
			iconObject = { "path": "icons/yaml.png" };
			break;
		case "js":
			iconObject = { "path": "icons/js.png" };
			break;
		case "zsh":
		case "sh":
			iconObject = { "path": "icons/shell.png" };
			break;
		case "rc":
			iconObject = { "path": "icons/rc.png" };
			break;
		case "": // = folder
		default:
			iconObject = { "type": "fileicon", "path": filePath }; // by default, use file icon
	}

	jsonArray.push({
		"title": fileName,
		"subtitle": "▸ " + twoParents,
		"match": alfredMatcher (fileName),
		"icon": iconObject,
		"type": "file:skipcheck",
		"uid": filePath,
		"arg": filePath,
	});
});

JSON.stringify({ items: jsonArray });
