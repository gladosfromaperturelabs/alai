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
sudo pacman -S network-manager-applet xorg-xinit xorg-server xdg-user-dirs-gtk nvidia opencl-nvidia ocl-icd firefox hexchat geary chromium firefox-i18n-es-es perl-json-xs perl-term-readline-gnu pulseaudio budgie-desktop arc-solid-gtk-theme adapta-gtk-theme papirus-icon-theme gtk-engine-murrine gtk-engines plank gnome-control-center gnome-screensaver gnome-keyring seahorse openssh libsecret dconf-editor file-roller nautilus gvfs-google gnome-calculator eog eog-plugins evince rhythmbox qt5-base qt5ct kvantum-qt5 qbittorrent gstreamer gst-libav gst-plugins-base gst-plugins-good gst-plugins-ugly gst-plugins-bad gst-libav libva-vdpau-driver libva-utils vdpauinfo mpv youtube-dl rtmpdump ttf-hack adobe-source-code-pro-fonts noto-fonts noto-fonts-emoji ttf-dejavu ttf-liberation hunspell hunspell-es hunspell-en aspell aspell-es aspell-en wine winetricks virtualbox virtualbox-host-modules-arch freerdp vinagre vala lua python-nautilus python-pipenv python2-pipenv python-pip python2-pip python-jedi python2-jedi meson ninja cmake clang gdb valgrind cppcheck glade libreoffice-fresh libreoffice-fresh-es libmythes mythes-en mythes-es hyphen hyphen-en hyphen-es linux-headers --needed --noconfirm

# Configure Xorg
sudo localectl set-x11-keymap es 105
echo 'QT_QPA_PLATFORMTHEME=qt5ct' | sudo tee --append /etc/environment

head -n -5 /etc/X11/xinit/xinitrc > ~/.xinitrc
echo 'eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)' >> ~/.xinitrc
echo 'export SSH_AUTH_SOCK' >> ~/.xinitrc
echo 'export XDG_CURRENT_DESKTOP=Budgie:GNOME' >> ~/.xinitrc
echo 'exec budgie-desktop' >> ~/.xinitrc

echo '#!/bin/sh' > ~/.xserverrc
echo 'exec /usr/bin/X -nolisten tcp -nolisten local "$@" vt$XDG_VTNR' >> ~/.xserverrc

echo 'if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then' >> ~/.bash_profile
echo '    exec startx -- -keeptty > ~/.xorg.log 2>&1' >> ~/.bash_profile
echo 'fi' >> ~/.bash_profile

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
gpg --keyserver pool.sks-keyservers.net --recv-keys 702353E0F7E48EDB 
trizen -S megasync gnome-mpv tilix-bin geany-gtk3 geany-plugins-gtk3 geany-jedi-complete-gtk3 virtualbox-ext-oracle --noconfirm --needed --noedit --noinfo

#sudo systemctl enable vmware-networks.service
#sudo systemctl enable vmware-usbarbitrator.service
#sudo /usr/lib/vmware/bin/vmware-vmx-debug --new-sn AG352-4YED3-0852Q-LPXXT-MGKG4

# Configure SUDO (disable use it without passowrd)
# sudo sed 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers > /tmp/sudoers.new
# sudo sed 's/%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/g' /tmp/sudoers.new > /tmp/sudoers.new
# EDITOR='cp /tmp/sudoers.new' sudo visudo

gsettings set org.gnome.desktop.interface gtk-theme "Arc-solid"
gsettings set org.gnome.desktop.interface icon-theme "Papirus"
gsettings set org.gnome.desktop.interface monospace-font-name "Source Code Pro 10"
gsettings set org.gnome.desktop.interface document-font-name "Noto Sans 10"
gsettings set org.gnome.desktop.interface font-name "Noto Sans 10"
gsettings set org.gnome.desktop.wm.preferences titlebar-font "Noto Sans 10"

sudo sync
sudo systemctl reboot

# END 20-firstboot.sh
