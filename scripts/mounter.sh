#!/usr/bin/env bash

actions="mount\nnothing\nEmacs\ndolphin\ngwenview"

pathtoname() {
    udevadm info -p /sys/"$1" | awk -v FS== '/DEVNAME/ {print $2}'
}

executeAction() {
		deviceName="$1"
		action="$2"
		if [ "$action" = "nothing" ]; then
				return
		fi
		# mount device and get the mount point path.
		mountPoint=$(udisksctl mount --block-device "$deviceName" --no-user-interaction \
										 | rev \
										 | cut -d " " -f1 \
										 | rev \
										 | sed 's/\.$//' \
							)
		# Execute action
		case "$action" in
				"mount" )
						(echo "$deviceName --> $mountPoint"; sleep 4) | dzen2 -bg darkred -fg grey80 -fn fixed
						;;
				"Emacs" )
						nohup emacsclient --socket-name /tmp/emacs1000/emacs-server-file "$mountPoint" </dev/null &>/dev/null &
						;;
				"gwenview" )
						nohup gwenview "$mountPoint" </dev/null &>/dev/null &
						;;
				"dolphin" )
						nohup dolphin "$mountPoint" </dev/null &>/dev/null &
						;;
		esac
}

stdbuf -oL -- udevadm monitor --udev -s block | while read -r -- eventCategory eventTime eventType devicePath dviceType; do

		# Skip event if device is not a partition (like /dev/sdb1), but a partition table (like /dev/sdb)
		echo "$devicePath" | sed '/[0-9]$/!{q1}'
		if [ $? -eq 1 ]; then
				continue
		fi

		devname=$(pathtoname "$devicePath")
		
		if [ "$eventType" = "add" ]; then
				echo "added"
				action=$(echo -e "$actions" | dmenu)
				executeAction "$devname" "$action"
		elif [ "$eventType" = "remove" ]; then
				(echo "$devname is removed"; sleep 2) | dzen2 -bg darkred -fg grey80 -fn fixed
		fi
done
