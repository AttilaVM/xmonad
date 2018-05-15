#!/usr/bin/env bash

projectBasis=$(cat << EndOfMessage
inkscape-icon
blend4web
EndOfMessage
			)

selected=$(echo -e "$projectBasis" | dmenu)

echo "$selected"

"$selected"
