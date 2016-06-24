#!/bin/bash

rm -rf pkglist qt5-* pyqt5

for name in dep opt; do
    echo "Downloading $name package list..."
    wget -q -O- "https://projects.archlinux.org/kde-build.git/plain/qt-${name}-packages?h=qt" | \
        grep -vE '(^#|^$)' >> pkglist
done

echo qt5-webkit >> pkglist
echo pyqt5 >> pkglist

rm -rf packages

while read pkg; do
    echo "Downloading $pkg..."
    git clone git://projects.archlinux.org/svntogit/packages.git \
        --branch=packages/$pkg --single-branch -q || exit 1
    cp -R packages/trunk $pkg || exit 1
    rm -r packages
done < pkglist
