#!/bin/bash

while [[ `ping -c2 google.com > /dev/null; echo $PIPESTATUS` != 0 ]]; do
		sel=0
		while [ $sel -eq 1  ] || [ !`ip link | egrep '^$sel'` ]; do
			ip link
			echo -n "Select the desired interface by number: "
			read sel
		done

		iface=`ip link | egrep '^$sel' | cut -d":" -f2 | cut -d" " -f2`
		if [[ `ip link | egrep -A1 '^$sel' | egrep 'link/ether'` ]]; then
				ip link set $iface down
				ip link set $iface up
				dhcpcd $iface
		else
				wifi-menu $iface
		fi
done

timedatectl set-ntp true

lsblk
echo -n "Which disk would you like to use: "
read diskpath
if [[ `ls /sys/firmware/efi/efivars` ]]; then
		echo; echo; echo -e This system uses efi, create an efi partition.; echo
		sleep 3s
fi
fdisk $diskpath

mkfs.ext4 `echo "$diskpath"1`
mkfs.ext4 `echo "$diskpath"2`
mkswap `echo "$diskpath"3`
swapon `echo "$diskpath"3`

mount `echo "$diskpath"1` /mnt
mkdir /mnt/boot
mount `echo "$diskpath"2` /mnt/boot

pacman -Sy pacman-contrib --noconfirm

grep -A1 --no-group-separator "United States" /etc/pacman.d/mirrorlist > /etc/pacman.d/mirrorlist.backup
rankmirrors -n 6 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist

pacstrap /mnt base

genfstab -U /mnt >> /mnt/etc/fstab
echo; echo; echo Check the file for errors; echo
sleep 3s
vim /mnt/etc/fstab

cp ./chroot.sh /mnt
arch-chroot /mnt ./chroot.sh

reboot

