#!/bin/bash

#Exit immediately if a command exits with a non-zero status (error)
set -e

# Updating and Ranking Pacman MirrorList.
mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

echo 'Reflector FR,DE,NL,PT,ES,GB,US (--age 12 --latest 100 --sort rate )... This will take a while...'
reflector --age 12 --latest 100 --sort rate --protocol https -c FR -c DE -c NL -c PT -c ES -c GB -c US --save /etc/pacman.d/mirrorlist.reflector

echo 'RankMirrors (fatest 20 from the Reflector List)... This will take some time...'
rankmirrors -n 20 /etc/pacman.d/mirrorlist.reflector > /etc/pacman.d/mirrorlist


# END pacmirrors.sh
