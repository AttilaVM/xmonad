#!/bin/bash
set -euo pipefail

tempFilePath=$(mktemp --tmpdir="/tmp" "screenshot-XXXX.png")

maim -s > "$tempFilePath"
# Render screenshot saving path
name="$HOME/screenshots/$(echo "" | dmenu)-$(date '+%Y-%m-%dT%T').png"
# Save image to path and clipboard
cat "$tempFilePath" \
  | tee "$name" \
  | xclip -selection clipboard -t image/png
