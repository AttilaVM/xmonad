#!/usr/bin/env bash
read -d '' help <<"EOF"
Help

Windows
M-n      Switch window
M-=      Kill active window
M-l      Focus down
M-j      Focus up
M-k      Swap Down
M-i      Swap Up
M-[      Shrink
m-]      Expand

Applications
M-;      Run application
M-o c    chromium
M-o c d  chromium-debug
M-o b    blender

Actions
M-h      Go to bookmark
M-b h    Hungarian layout
M-b u    US layout
end
EOF

echo -e "$help"

echo -ne "$help" | dzen2 -l 42 -p -e "button1=exit;onstart=uncollapse;button4=scrollup;button5=scrolldown"
