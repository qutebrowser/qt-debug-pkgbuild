#!/bin/bash

set -e

[[ ! $PACKAGES ]] && PACKAGES=$(cat pkglist)

# Always build qt5-base so we can be sure we have debugging symbol settings in
# QT_CONFIG for other modules
if [[ $PACKAGES != *qt5-base* ]]; then
    pushd qt5-base
    sudo pacman -Rdd --noconfirm qt5-base
    makepkg -i -f --noconfirm
    popd
fi

for pkg in $PACKAGES; do
    pushd $pkg

    # Remove the thing we're building so we can install -debug easily.
    [[ $pkg == pyqt5 ]] && pkg="python-pyqt5 python2-pyqt5"
    [[ $pkg == pyqtwebengine ]] && pkg="python-pyqtwebengine python2-pyqtwebengine"
    sudo pacman -Rdd --noconfirm $pkg || true

    makepkg -i -f --noconfirm
    popd
done
