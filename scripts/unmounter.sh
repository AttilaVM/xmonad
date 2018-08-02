#!/usr/bin/env bash

devices=$(udisksctl status \
							| tail -n +3 \
							| sed -r 's/(\ *$|^\ *)//g' \
							| sed -r 's/\ {1,50}/ /g' \
							| rev \
							| cut -d " " -f1 \
							| rev
			 )

usbDevices=""
while read -r deviceName; do
    deviceInfo=$(udisksctl info --block-device "/dev/$deviceName")

		# check if device is USB device
		echo "$deviceInfo" | grep -E "\/dev\/disk\/by-path\/pci-[0-9:a-z.]{12}-usb" > /dev/null
		if [ $? -eq 0 ]; then
				partitionData=$(lsblk | grep "$deviceName" | grep -E "└─sd[a-z][0-9]" \
														| sed 's/└─//g')
				partitionDevFile=$(echo "$partitionData" | cut -d " " -f1)
				partitionMountPath=$(udisksctl info --block-device "/dev/$partitionDevFile" \
																 | grep "MountPoints:" \
																 | sed -r 's/(\ *$|^\ *)//g' \
																 | sed -r 's/\ {1,100}/ /g' \
																 # | cut -d " " -f2
													)
				if [ "$partitionMountPath" != "MountPoints:" ]; then
						usbDevices="$usbDevices\n/dev/$partitionDevFile $partitionMountPath"
				fi
		fi
		
done <<< "$devices"

echo -e "$usbDevices"
read -r deviceFile mountPath < <(echo -e "$usbDevices" | dmenu)

echo "$deviceFile"

# udisksctl unmount -b "$deviceFile" | dzen2 -bg darkred -fg grey80 -fn fixed

(udisksctl unmount -b "$deviceFile"; sleep 4) | dzen2 -bg darkgreen -fg grey80 -fn fixed

# /dev/disk/by-path/pci-0000:00:1d.0-usb
