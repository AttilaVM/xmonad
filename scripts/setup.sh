#!/usr/bin/env bash

xrandr --auto --output DP-1 --mode 1920x1200 --right-of HDMI-1

# turn on num lock
xdotool key Num_Lock
xsetroot -cursor_name left_ptr
xsetroot -solid "#272822"

# Make modifier keys act as regular keys when pressed and released alone under a time limit
# but before if there is a previously running xcape process kill it.
killall -9 xcape
xcape -t 150 -e "Hyper_L=Insert;Alt_L=Tab;Alt_R=Return"
