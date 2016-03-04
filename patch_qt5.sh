#!/bin/bash

for pkg in qt5-*; do
    echo >> "$pkg/PKGBUILD"
    echo "provides+=(\"$pkg=\$pkgver\")" >> "$pkg/PKGBUILD"
    echo "conflicts+=(\"$pkg\")" >> "$pkg/PKGBUILD"
    echo "options+=('debug' '!strip')" >> "$pkg/PKGBUILD"
    sed -i 's/pkgname=qt5-.*/&-debug/' "$pkg/PKGBUILD"
done

if ! grep -q ' -debug' qt5-base/PKGBUILD; then
    echo "qt5-base PKGBUILD does not contain -debug!" >&2
    exit 1
fi
