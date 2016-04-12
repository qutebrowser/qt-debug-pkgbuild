#!/bin/bash

set -e

[[ ! $PACKAGES ]] && PACKAGES=$(cat pkglist)

for pkg in $PACKAGES; do
    cd ~/$pkg
    makepkg -i --noconfirm
done
