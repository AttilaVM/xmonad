#!/usr/bin/env bash

projectBasis=$(cat << EndOfMessage
inkscape-icon
inkscape-gui
EndOfMessage
			)

selected=$(echo -e "$projectBasis" | dmenu)

echo "$selected"

"$selected"
