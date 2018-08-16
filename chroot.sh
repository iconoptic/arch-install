#!/bin/bash

ln -sf /usr/share/zoneinfo/US/Mountain /etc/localtime
hwclock --systohc

sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo -n "Enter the desired hostname: "
read hostname
echo $hostname > /etc/hostname

echo -e "127.0.0.1\tlocalhost" >> /etc/hosts
echo -e "::1\t\tlocalhost" >> /etc/hosts
echo -e "127.0.0.1\t$hostname.localdomain\t$hostname" >> /etc/hosts

echo Update the root password.
passwd

pacman -S syslinux
syslinux-install_update -i -a -m

useradd -U -m btgrant
echo "btgrant password:"
passwd btgrant

pacman -S i3 i3-gaps --noconfirm
echo exec_i3 >> /home/btgrant/.xinitrc
