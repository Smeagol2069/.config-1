#!/bin/zsh

# input args
URL="$1"
OUTPUT_FOLDER="$2"
[[ -z "$URL" ]] && exit 1
[[ -z "$OUTPUT_FOLDER" ]] && OUTPUT_FOLDER="."

# install dependencies
if ! command mercury-parser ; then
	echo "mercury-parser not installed."
	echo "install: npm -g install @postlight/mercury-parser"
fi
if ! command turndown-cli ; then
	echo "turndown-cli not installed."
	echo "install: npm -g install turndown-cli"
fi
if ! command yq ; then
	echo "yq not installed."
	echo "install: brew install yq"
fi
if ! command mercury-parser ; then
	echo "mercury-parser not installed."
	echo "install: npm -g install @postlight/mercury-parser"
fi
if ! command markdownlint ; then
	echo "markdownlint not installed."
	echo "install: brew markdownlint-cli"
fi
if ! command gather ; then
	echo "gather-cli not installed."
	echo "Install from here: https://github.com/ttscoff/gather-cli"
	echo "(brew tap requires 12gb Xcode install, so download the package instead…)"
	exit 1
fi

# Mercury Reader Version
parsed_data=$(mercury-parser "$URL")
title=$(echo "$parsed_data" | yq .title)
safe_title=$(echo "$title" | tr "/:;.\\" "-----")
content=$(echo "$parsed_data" | yq .content | markdownlint --fix --quiet --stdin)
author=$(echo "$parsed_data" | yq .author)
date_published=$(echo "$parsed_data" | yq .date_published | cut -d"T" -f1)
excerpt=$(echo "$parsed_data" | yq .excerpt)
word_count=$(echo "$parsed_data" | yq .word_count)

frontmatter=$(echo "---" ; echo "title: $title" ; echo "author: $author" ; echo "date: $date_published" ; echo "excerpt: $excerpt" echo "word: $word_count" ; echo "source: $URL" ; echo "---" ; echo)
turndown-cli --head=2 --hr=2 --bullet=2 --code=2 temp.html
rm ./*.html ./*.md
output1="$frontmatter\n$content"

# Gather Version
output2=$(gather --inline-links --no-include-source "$URL" | markdownlint --fix --quiet --stdin)

# Output & Diff
# (Diff as a form of quality control)
echo "$output1" > "$OUTPUT_FOLDER/${safe_title}_a.md"
echo "$output2" > "$OUTPUT_FOLDER/${safe_title}_b.md"
# TODO: run diff comparing the two
