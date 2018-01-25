#!/bin/bash

# Exit immediately if a command exits with a non-zero status (error)
set -e

# This is to dont load again the script
rm /home/glados/.bash_profile && cp /etc/skel/.bash_profile /home/glados

# Time Internte Sync
sudo timedatectl set-ntp true

sleep 5;
ping -c 5 google.com

# Update/Upgrade/Optimize Pacman DB/PKGs 
sudo pacman -Syyu
sudo pacman-optimize

# Install Basic Mate Desktop and Apps
sudo pacman -S xorg-xinit cmake xorg-server xorg-xwininfo xorg-xprop xdg-user-dirs-gtk nvidia firefox chromium firefox-i18n-es-es perl-json-xs perl-term-readline-gnu pulseaudio network-manager-applet mate mate-extra adapta-gtk-theme papirus-icon-theme gtk-engine-murrine compton plank gstreamer gst-libav gst-plugins-base gst-plugins-good gst-plugins-ugly gst-plugins-bad gst-libav libva-vdpau-driver libva-utils vdpauinfo mpv youtube-dl phantomjs rtmpdump ttf-hack adobe-source-code-pro-fonts noto-fonts noto-fonts-emoji ttf-dejavu --needed --noconfirm

# Configure Xorg
head -n -5 /etc/X11/xinit/xinitrc > ~/.xinitrc
echo 'exec mate-session' >> ~/.xinitrc
echo '#!/bin/sh' > ~/.xserverrc
echo 'exec /usr/bin/X -nolisten tcp -nolisten local "$@" vt$XDG_VTNR' >> ~/.xserverrc
echo 'if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then' >> ~/.bash_profile
echo '    exec startx -- -keeptty > ~/.xorg.log 2>&1' >> ~/.bash_profile
echo 'fi' >> ~/.bash_profile

sudo systemctl enable nvidia-persistenced

# Installing Trizen AUR Helper (pacaur is discontinued)
mkdir /tmp/trizen &&cd /tmp/trizen && git clone https://aur.archlinux.org/trizen.git
cd trizen && makepkg -Ccirs --noconfirm --needed
trizen -S mate-tweak brisk-menu --noconfirm --needed --noedit

# Configure SUDO (disable use it without passowrd)
sudo sed 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers > /tmp/sudoers.new
sudo sed 's/%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/g' /tmp/sudoers.new > /tmp/sudoers.new
EDITOR='cp /tmp/sudoers.new' sudo visudo


# END 20-firstboot.sh
