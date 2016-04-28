#!/bin/bash

set -e

[[ ! $PACKAGES ]] && PACKAGES=$(cat pkglist)

for pkg in $PACKAGES; do
    cd ~/$pkg

    # Remove the thing we're building so we can install -debug easily.
    [[ $pkg == pyqt5 ]] && pkg="pyqt5-common python-pyqt5 python2-pyqt5"
    sudo pacman -Rdd --noconfirm $pkg

    makepkg -i -f --noconfirm
done
