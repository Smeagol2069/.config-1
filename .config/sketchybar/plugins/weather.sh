#!/usr/bin/env sh

weather=$(curl "https://wttr.in/Berlin?format=1" | cut -d"+" -f2)
[[ "$weather" =~ "Unknown" ]] && weather="–"
sketchybar --set "$NAME" label="$weather"

