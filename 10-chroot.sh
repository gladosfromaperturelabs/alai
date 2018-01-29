#!/bin/bash

# Exit immediately if a command exits with a non-zero status (error)
set -e

# Set Time Zone, hwclock, locale, console keymap
ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime
hwclock --systohc --utc
echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
echo 'es_ES.UTF-8 UTF-8' >> /etc/locale.gen
locale-gen
echo 'LANG=es_ES.UTF-8' > /etc/locale.conf
echo 'KEYMAP=es' > /etc/vconsole.conf

# Host
echo 'aperture' > /etc/hostname
echo '127.0.0.1		localhost.localdomain	localhost' >> /etc/hosts
echo '::1		localhost.localdomain	localhost' >> /etc/hosts
echo '127.0.0.1		aperture.localdomain	aperture' >> /etc/hosts

# NetworkManager
ln -sf /usr/lib/systemd/system/NetworkManager.service /etc/systemd/system/dbus-org.freedesktop.NetworkManager.service
ln -sf /usr/lib/systemd/system/NetworkManager.service /etc/systemd/system/multi-user.target.wants/NetworkManager.service
ln -sf /usr/lib/systemd/system/NetworkManager-dispatcher.service /etc/systemd/system/dbus-org.freedesktop.nm-dispatcher.service

# Modules blacklist
echo 'blacklist sp5100_tco' > /etc/modprobe.d/sp5100tco-blacklist.conf
echo 'blacklist nouveau' > /etc/modprobe.d/nouveau-blacklist.conf
echo 'options nouveau modeset=0' >> /etc/modprobe.d/nouveau-blacklist.conf

echo 'blacklist kvm' > /etc/modprobe.d/kvm-blacklist.conf
echo 'blacklist kvm_amd' >> /etc/modprobe.d/kvm-blacklist.conf

# Disable SystemD Journal Logs on disk
rm -R /var/log/journal

# Disable core dumps
mkdir /etc/systemd/coredump.conf.d/
echo '[Coredump]' >> /etc/systemd/coredump.conf.d/custom.conf
echo 'Storage=none' >> /etc/systemd/coredump.conf.d/custom.conf

# Set Nano as default console text editor
echo 'EDITOR=nano' >> /etc/environment

# Configure SUDO
sed 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers > /tmp/sudoers.new
EDITOR='cp /tmp/sudoers.new' visudo


# Configure Pacman
sed -i 's/#Color/Color/g' /etc/pacman.conf
sed -i 's/#TotalDownload/TotalDownload/g' /etc/pacman.conf
sed -i 's/#VerbosePkgLists/VerbosePkgLists/g' /etc/pacman.conf

# Enable Multilib Pacman Repo
echo '[multilib]' >> /etc/pacman.conf
echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf

# Configure makepkg.conf
sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j$(nproc)"/g' /etc/makepkg.conf
sed -i 's/COMPRESSGZ=(gzip -c -f -n)/COMPRESSGZ=(pigz -c -f -n)/g' /etc/makepkg.conf
sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -z - --threads=0)/g' /etc/makepkg.conf

# BootLoader GRUB with Custom resolution (FIX for NVIDIA booting in HiRes)
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=arch-grub
sed -i 's/GRUB_GFXMODE=auto/GRUB_GFXMODE=1920x1080-24/g' /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT="nomodeset"/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# FIX for VirtualBox UEFI mode
echo '\EFI\arch-grub\grubx64.efi' > /boot/startup.nsh

# Configure Automatic User Login and keep boot messages
mkdir /etc/systemd/system/getty@tty1.service.d/
overr_getty1=/etc/systemd/system/getty@tty1.service.d/override.conf
echo '[Service]' > $overr_getty1
echo 'ExecStart=' >> $overr_getty1
echo 'ExecStart=-/usr/bin/agetty --autologin glados --noclear %I $TERM' >> $overr_getty1
echo 'TTYVTDisallocate=no' >> $overr_getty1
echo 'Type=simple' >> $overr_getty1

# Add User GLaDOS
echo 'Usuario GLaDOS (glados)'
useradd -m -G wheel -s /bin/bash glados
passwd glados

# Disable root user for security
passwd -l root

#20-firstboot.sh script next reboot

echo 'exec /alai-scripts/20-firstboot.sh' >> /home/glados/.bash_profile

# exit chroot/

exit

# END 10-chroot.sh
