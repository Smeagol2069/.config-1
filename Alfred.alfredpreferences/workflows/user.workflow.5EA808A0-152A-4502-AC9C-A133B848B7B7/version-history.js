#!/usr/bin/env osascript -l JavaScript

function run (argv) {
	ObjC.import("stdlib");
	const app = Application.currentApplication();
	app.includeStandardAdditions = true;

	function finderSelection () {
		const sel = decodeURI(Application("Finder").selection()[0]?.url());
		if (sel === "undefined") return ""; // no selection
		return sel.slice(7);
	}

	const fileExists = (filePath) => Application("Finder").exists(Path(filePath));

	const filePathRegex = /(\/.*)\/(.*\.(\w+))$/;

	function alfredErrorDisplay (text) {
		const item = [{ "title": text }];
		return JSON.stringify({ items: item });
	}

	//------------------------------------------------------------------------------
	const query = argv.join("");

	let fullPath;
	try {
		fullPath = $.getenv("input");
	} catch (error) {
		fullPath = finderSelection();
		if (!fullPath) return alfredErrorDisplay("No selection");
	}

	const isRegularFile = fullPath.match(filePathRegex);
	if (!isRegularFile) return alfredErrorDisplay("Not a regular file");

	const parentFolder = fullPath.replace(filePathRegex, "$1");
	const isGitRepo = app.doShellScript(`cd "${parentFolder}" ; git rev-parse --git-dir || echo "not a git directory"`).endsWith(".git");
	if (!isGitRepo) return alfredErrorDisplay("Not a git directory");

	const fileName = fullPath.replace(filePathRegex, "$2");
	const safeFileName = fileName.replace(/[/: .]/g, "-");
	const ext = fullPath.replace(filePathRegex, "$3");
	const fileIcon = { "type": "fileicon", "path": fullPath };
	const tempDir = `/tmp/${safeFileName}`;

	//------------------------------------------------------------------------------

	const firstRun = query === "";
	let firstItem = true;
	let historyMatches;
	let extraOptions = "";
	if (firstRun) extraOptions = ";%ad;%s;%an";

	// write versions into temporary directory
	const logLines = app.doShellScript(`cd "${parentFolder}" ; git log --pretty=format:"%h${extraOptions}" --date=human "${fullPath}"`)
		.split("\r");
	app.doShellScript(`mkdir -p ${tempDir}`);
	logLines.forEach(logLine => {
		const commitHash = logLine.split(";")[0];
		const tempPath = `${tempDir}/${commitHash}.${ext}`;
		if (!fileExists(tempPath)) {
			app.doShellScript(`cd "${parentFolder}" ; git show "${commitHash}:./${fileName}" > "${tempPath}"`);
		}
	});

	// show all versions of file with commit message, author. Sorted by commit date.
	if (firstRun) {
		historyMatches = logLines.map(logLine => {
			const commitHash = logLine.split(";")[0];
			const date = logLine.split(";")[1];
			const commitMsg = logLine.split(";")[2];
			const author = logLine.split(";")[3];
			const filePath =`${tempDir}/${commitHash}.${ext}`;

			const subtitle = `${commitMsg}  ▪︎  ${author}`;

			let appendix = "";
			if (firstItem) {
				appendix = "  ▪︎  " + fileName;
				firstItem = false;
			}

			return {
				"title": date + appendix,
				"subtitle": subtitle,
				"quicklookurl": filePath,
				"mods": {
					"cmd": { "arg": `${filePath};${fullPath}` }, // old;new file for diff view
					"alt": {
						"arg": commitHash,
						"subtitle": `${commitHash}    (⌥: Copy)`
					},
				},
				"icon": fileIcon,
				"arg": `${filePath}`,
			};

		});

	// search versions with ripgrep & display git commit info for matched versions
	} else {
		historyMatches = app.doShellScript(`export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ; cd "${tempDir}" ; rg --max-count=1 --line-number --smart-case "${query}"`)
			.split("\r")
			.map(rgMatch => {
				const commitHash = rgMatch.split(".")[0];
				const file = rgMatch.split(":")[0];
				const line = rgMatch.split(":")[1];
				const firstMatch = rgMatch.split(":")[2].trim();
				const date = app.doShellScript(`cd "${parentFolder}" ; git show -s --format=%ad --date=human ${commitHash}`);
				const filePath =`${tempDir}/${file}`;

				let appendix = "";
				if (firstItem) {
					appendix = "  ▪︎  " + fileName;
					firstItem = false;
				}

				return {
					"title": date + appendix,
					"subtitle": firstMatch,
					"quicklookurl": filePath,
					"mods": {
						"cmd": { "arg": `${filePath};${fullPath}` }, // old;new file for diff view
						"alt": {
							"arg": commitHash,
							"subtitle": `${commitHash}    (⌥: Copy)`
						},
					},
					"icon": fileIcon,
					"arg": `${filePath}:${line}`,
				};

			});
	}

	return JSON.stringify({ items: historyMatches });
}
