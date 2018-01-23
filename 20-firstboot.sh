#!/bin/bash

# Exit immediately if a command exits with a non-zero status (error)
set -e

# This is to dont load again the script
rm /home/glados/.bash_profile && cp /etc/skel/.bash_profile /home/glados

# Time Internte Sync
sudo timedatectl set-ntp true
ping -c 4 google.com

# Update/Upgrade/Optimize Pacman DB/PKGs 
sudo pacman -Syyu
sudo pacman-optimize

# Install Basic Plasma Desktop
sudo pacman -S xorg-server plasma-desktop xdg-user-dirs nvidia plasma-nm konsole firefox qupzilla dolphin dolphin-plugins kate kcalc ark okular gwenview kimageformats kipi-plugins qt5-imageformats sddm sddm-kcm kde-gtk-config breeze-gtk pulseaudio plasma-pa --needed --noconfirm

# Install some transtalations (Spanish)
sudo pacman -S firefox-i18n-es-es qt5-translations hunspell-en hunspell-es --needed --noconfirm

# Multimedia and Codecs
sudo pacman -S gstreamer gst-libav gst-plugins-base gst-plugins-good gst-plugins-ugly gst-plugins-bad gst-libav libva-vdpau-driver libva-utils vdpauinfo mpv vlc cantata youtube-dl phantomjs rtmpdump --needed --noconfirm

# IDE and tools for Developers
sudo pacman -S cmake kdevelop kdevelop-python cppcheck kdevelop-pg-qt kompare powerline --needed --noconfirm
 
# Fonts
sudo pacman -S powerline-fonts awesome-terminal-fonts ttf-hack adobe-source-code-pro-fonts noto-fonts noto-fonts-emoji ttf-dejavu --needed --noconfirm

# Configure Powerline
echo 'powerline-daemon -q' >> ~/.bashrc
echo 'POWERLINE_BASH_CONTINUATION=1' >> ~/.bashrc
echo 'POWERLINE_BASH_SELECT=1' >> ~/.bashrc
echo '. /usr/lib/python3.6/site-packages/powerline/bindings/bash/powerline.sh' >> ~/.bashrc

# Enable SSDM and nVidia Services
sudo systemctl enable sddm.service
sudo systemctl enable nvidia-persistenced

# Installing Trizen AUR Helper (pacaur is discontinued)
cd /tmp/trizen && git clone https://aur.archlinux.org/trizen.git
cd trizen && makepkg -Ccirs --noconfirm --needed
sudo pacman -S perl-json-xs perl-term-readline-gnu --noconfirm --needed

# Configure SUDO (disable use it without passowrd)
sed 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers > /etc/sudoers.new
EDITOR='cp /etc/sudoers.new' visudo
rm /etc/sudoers.new

# END 20-firstboot.sh
