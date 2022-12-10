#!/usr/bin/env osascript -l JavaScript
let karabinerJSON = "~/.config/karabiner/karabiner.json";
let customRulesJSONlocation = "~/.config/karabiner/assets/complex_modifications/";
//------------------------------------------------------------------------------
const app = Application.currentApplication();
app.includeStandardAdditions = true;
ObjC.import("Foundation");
function readFile(path, encoding) {
	if (!encoding) encoding = $.NSUTF8StringEncoding;
	const fm = $.NSFileManager.defaultManager;
	const data = fm.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, encoding);
	return ObjC.unwrap(str);
}
function writeToFile(text, file) {
	const str = $.NSString.alloc.initWithUTF8String(text);
	str.writeToFileAtomicallyEncodingError(file, true, $.NSUTF8StringEncoding, null);
}
//------------------------------------------------------------------------------

function main() {
	karabinerJSON = karabinerJSON.replace(/^~/, app.pathTo("home folder"));
	customRulesJSONlocation = customRulesJSONlocation.replace(/^~/, app.pathTo("home folder"));

	const yqNotInstalled = app.doShellScript("command yq || echo false") === "false";
	if (yqNotInstalled) return "Karabiner Config Build: ❌ yq is not installed.";

	// convert yaml to json (requires `yq`)
	// using `explode` to expand anchors & aliases: https://mikefarah.gitbook.io/yq/operators/anchor-and-alias-operators#explode-alias-and-anchor
	app.doShellScript(`
		export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
		cd "$HOME/.config/karabiner/assets/complex_modifications/" || exit 1
		for f in *.yaml ; do
			f=$(basename "$f" .yaml)
			yq -o=json 'explode(.)' "$f.yaml" > "$f.json"
		done
	`);

	// built new karabiner.json out of single jsons
	const customRules = [];
	app.doShellScript(`ls "${customRulesJSONlocation}" | grep ".json"`)
		.split("\r")
		.forEach(fileName => {
			const filePath = customRulesJSONlocation + fileName;
			const ruleSet = JSON.parse(readFile(filePath)).rules;
			ruleSet.forEach(rule => customRules.push(rule));
			app.doShellScript(`rm "${filePath}"`); // delete leftover JSON
		});
	const complexRules = JSON.parse(readFile(karabinerJSON));

	// INFO: the rules are added to the *first* profile in the profile list from Karabiner.
	complexRules.profiles[0].complex_modifications.rules = customRules;

	writeToFile(JSON.stringify(complexRules), karabinerJSON);

	// validate
	const lintStatus = app.doShellScript(`"/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli" --lint-complex-modifications "${karabinerJSON}"`).trim();
	const msg = lintStatus === "ok" ? "✅ Build Success" : "🛑 Config Invalid";

	return `Karabiner Config: \n ${msg}`;
}

main();
