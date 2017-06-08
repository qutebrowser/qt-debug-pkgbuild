#!/bin/bash

set -e

[[ ! $PACKAGES ]] && PACKAGES=$(cat pkglist)

# Always build qt5-base so we can be sure we have debugging symbol settings in
# QT_CONFIG for other modules
if [[ $PACKAGES != *qt5-base* ]]; then
    cd ~/qt5-base
    sudo pacman -Rdd --noconfirm qt5-base
    makepkg -i -f --noconfirm
fi

for pkg in $PACKAGES; do
    cd ~/$pkg

    # Remove the thing we're building so we can install -debug easily.
    [[ $pkg == pyqt5 ]] && pkg="pyqt5-common python-pyqt5 python2-pyqt5"
    sudo pacman -Rdd --noconfirm $pkg || true

    makepkg -i -f --noconfirm
done
