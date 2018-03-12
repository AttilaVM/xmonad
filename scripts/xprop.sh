#!/usr/bin/env bash

windowProps=$(xprop)
windowName=$(echo "$windowProps" \
								 | grep "WM_CLASS(STRING)" \
								 | grep -o '".*"')
echo -n "$windowProps" | xclip -selection clipboard
echo -ne "Xproperties: $windowName\n$windowProps" | dzen2 -l "$DZEN_HEIGHT" -p -e "button1=exit;onstart=uncollapse;button4=scrollup;button5=scrolldown" -w "$DZEN_WIDTH"
