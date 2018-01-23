#!/bin/bash

# Exit immediately if a command exits with a non-zero status (error)
set -e

# Check UEFI
[ -d /sys/firmware/efi ] && echo 'UEFI: OK' || { echo 'UEFI: FAIL'; exit; }

# Set keyboard layout
loadkeys es
echo 'Keyboard: ES'

# Set system clock with NTP and timezone
timedatectl set-ntp true
timedatectl set-timezone Europe/Madrid
echo 'Clock & TZ:' $(date +'%d/%m/%Y %k:%M:%S %:z %Z')

# Clean, Partition and mount the disk
lsblk -p -l -d -S -o NAME,SIZE,MODEL,RM | grep '^/dev/sd[a-z].*0$' | sed 's/.$//'

read -p 'Disk to use (also WIPES ALL DATA), expample /dev/sdX: ' diskpath

arr_devpath=( $(lsblk -n -p -r -a -o NAME | grep '^"$diskpath"' | tac) )

for devpath in "${arr_devpath[@]}"; do
   wipefs -a $devpath
done

sgdisk -Z $diskpath
sgdisk -o $diskpath
sgdisk -n 0:0:+500M -t 0:ef00 -c 0:'arch-boot' $diskpath
sgdisk -n 0:0:0 -t 0:8300 -c 0:'arch-root' $diskpath

partprobe $diskpath
fdisk -l $diskpath

partid_archboot=1
partid_archroot=2

mkfs.vfat -F 32 -n 'arch-boot' $diskpath$partid_archboot
yes | mkfs.ext4 -L 'arch-root' $diskpath$partid_archroot

mount -o discard,noatime $diskpath$partid_archroot /mnt
mkdir /mnt/boot
mount -o discard,noatime $diskpath$partid_archboot /mnt/boot

pacman -Syy
pacman -S reflector unzip --noconfirm

# Updating and Ranking Pacman MirrorList.
mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

echo 'Reflector FR,DE,ES (--age 12 --latest 50 --sort rate )...'
reflector --age 12 --latest 50 --sort rate --protocol https -c FR -c DE -c ES --save /etc/pacman.d/mirrorlist.reflector

echo 'RankMirrors (fatest 10 from the Reflector List)...'
rankmirrors -n 10 /etc/pacman.d/mirrorlist.reflector > /etc/pacman.d/mirrorlist

# pacstrap system
pacstrap /mnt base base-devel grub efivar efibootmgr networkmanager reflector wget git pigz unrar zip unzip p7zip bash_completion

# genfstab by Label
genfstab -L /mnt >> /mnt/etc/fstab

# Updated and Ranked Pacman Mirrorlist
mv /mnt/etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist.bak
cp /etc/pacman.d/mirrorlist* /mnt/etc/pacman.d/

# Copy ArchLinux AutoInstall Scripts
curl -L --output aai-scripts.zip https://github.com/gladosfromaperturelabs/alai/archive/master.zip
mkdir /mnt/alai-scripts
unzip -j alai-scripts.zip -d /mnt/alai-scripts
chmod +x /mnt/alai-scripts/*

# chroot into new system and continue
arch-chroot /mnt /alai-scripts/10-chroot.sh

# When exit from chroot
sync
umount -R /mnt

# Reboot
reboot

# END 00-pre-chroot.sh
