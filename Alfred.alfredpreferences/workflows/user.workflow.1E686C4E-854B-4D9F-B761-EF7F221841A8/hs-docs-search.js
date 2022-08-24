#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
const alfredMatcher = (str) => str.replace (/[-()_.]/g, " ") + " " + str + " ";
ObjC.import("Foundation");
function readFile (path, encoding) {
	if (!encoding) encoding = $.NSUTF8StringEncoding;
	const fm = $.NSFileManager.defaultManager;
	const data = fm.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, encoding);
	return ObjC.unwrap(str);
}


const workArray = JSON.parse(readFile("/Applications/Hammerspoon.app/Contents/Resources/docs.json"))
	.tree
	.filter(file => file.path.startsWith("docs/hs"))
	.map(file => {
		const subsite = file.path.slice(5, -5); // remove "/docs" and ".html"
		return {
			"title": subsite,
			"match": alfredMatcher (subsite),
			"arg": `https://www.hammerspoon.org/docs/${subsite}.html`,
			"uid": subsite,
		};
	});

// individual pages
workArray.push({
	"title": "Getting Started",
	"match": "getting started examples",
	"arg": "https://www.hammerspoon.org/go/",
	"uid": "getting-started",
});
workArray.push({
	"title": "Hammerspoon Keymaps",
	"match": "keymaps keycode hotkey",
	"arg": "https://www.hammerspoon.org/docs/hs.keycodes.html#map",
	"uid": "keymaps",
});
workArray.push({
	"title": "hs.execute",
	"match": "shell execute hs hs.execute",
	"arg": "https://www.hammerspoon.org/docs/hs.html#execute",
	"uid": "execute",
});

JSON.stringify({ items: workArray });
