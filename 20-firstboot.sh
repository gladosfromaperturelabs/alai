#!/bin/bash

# Exit immediately if a command exits with a non-zero status (error)
set -e

# This is to dont load again the script
rm /home/glados/.bash_profile && cp /etc/skel/.bash_profile /home/glados

# Time Internte Sync
sudo timedatectl set-ntp true

sleep 7
ping -c 5 google.com

# Update/Upgrade/Optimize Pacman DB/PKGs 
sudo pacman -Syyu
sudo pacman-optimize

# Install Basic Mate Desktop and Apps
sudo pacman -S xorg-xinit xorg-xwininfo xorg-xprop xorg-server xdg-user-dirs nvidia opencl-nvidia ocl-icd lib32-nvidia-utils lib32-opencl-nvidia lib32-ocl-icd perl-json-xs perl-term-readline-gnu pulseaudio qbittorrent gstreamer gst-libav gst-plugins-base gst-plugins-good gst-plugins-ugly gst-plugins-bad gst-libav libva-vdpau-driver libva-utils vdpauinfo mps-youtube mpv youtube-dl rtmpdump ttf-hack adobe-source-code-pro-fonts ttf-dejavu ttf-liberation hunspell hunspell-es hunspell-en aspell aspell-es aspell-en wine winetricks virtualbox virtualbox-host-modules-arch libmythes mythes-en mythes-es hyphen hyphen-en hyphen-es linux-headers plasma-desktop plasma-nm plasma-pa dolphin kde-gtk-config breeze-gtk konsole kate okular gwenview qt5-translations qt5-imageformats kipi-plugins kimageformats discount ebook-tools spectacle kcalc ksshaskpass kwalletmanager kwallet ark megasync dolphin-megasync qupzilla lazarus lazarus-qt5 qtcreator cmake extra-cmake-modules meson ninja llvm clang jdk9-openjdk jre9-openjdk python2 python2-pip python-pip jsoncpp cppcheck valgrind openmp gdb ntfs-3g exfat-utils rust go lua lua51 lua52 libreoffice-fresh libreoffice-fresh-es adapta-kde kvantum-theme-adapta adapta-gtk-theme papirus-icon-theme gtk-engine-murrine noto-fonts noto-fonts-emoji ttf-roboto qt5-doc qt5-examples kleopatra --needed --noconfirm

# Configure Xorg
sudo localectl set-x11-keymap es 105

head -n -5 /etc/X11/xinit/xinitrc > ~/.xinitrc
echo 'exec startkde' >> ~/.xinitrc

echo '#!/bin/sh' > ~/.xserverrc
echo 'exec /usr/bin/X -nolisten tcp -nolisten local "$@" vt$XDG_VTNR' >> ~/.xserverrc

echo 'if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then' >> ~/.bash_profile
echo '    exec startx -- -keeptty > ~/.xorg.log 2>&1' >> ~/.bash_profile
echo 'fi' >> ~/.bash_profile

mkdir -p /home/glados/.config/autostart-scripts
cp /alai-scripts/plasma-5-noshadow.sh /home/glados/.config/autostart-scripts/
chmod +x /home/glados/.config/autostart-scripts/plasma-5-noshadow.sh

# nVidia Xorg config file with fixes for plasma
sudo cp /alai-scripts/20-nvidia.conf /etc/X11/xorg.conf.d/20-nvidia.conf
sudo systemctl enable nvidia-persistenced

# git
git config --global user.name  "GLaDOS"
git config --global user.email "gladosfromaperturelabs@gmail.com"
git config --global credential.helper /usr/lib/git-core/git-credential-libsecret

# VirtualBox
sudo usermod -aG vboxusers glados
sudo modprobe vboxdrv

# Installing Trizen AUR Helper (pacaur is discontinued)
mkdir /tmp/trizen && cd /tmp/trizen && git clone https://aur.archlinux.org/trizen.git
cd trizen && makepkg -Ccirs --noconfirm --needed
mkdir -p /home/glados/.config/trizen/
cp /alai-scripts/trizen.conf /home/glados/.config/trizen/
trizen -S virtualbox-ext-oracle visual-studio-code-bin --noconfirm --needed --noedit --noinfo

# Configure SUDO (disable use it without passowrd)
# sudo sed 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers > /tmp/sudoers.new
# sudo sed 's/%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/g' /tmp/sudoers.new > /tmp/sudoers.new
# EDITOR='cp /tmp/sudoers.new' sudo visudo

#gsettings set org.gnome.desktop.interface gtk-theme "Arc-solid"
#gsettings set org.gnome.desktop.interface icon-theme "Papirus"
#gsettings set org.gnome.desktop.interface monospace-font-name "Source Code Pro 10"
#gsettings set org.gnome.desktop.interface document-font-name "Noto Sans 10"
#gsettings set org.gnome.desktop.interface font-name "Noto Sans 10"
#gsettings set org.gnome.desktop.wm.preferences titlebar-font "Noto Sans 10"

sudo sync
sudo systemctl reboot

# END 20-firstboot.sh
