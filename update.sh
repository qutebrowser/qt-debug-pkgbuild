#!/bin/bash

if (( $# == 0 )); then
    rm -f pkglist
    for name in dep opt; do
        echo "Downloading $name package list..."
        wget -q -O- "https://projects.archlinux.org/kde-build.git/plain/qt-${name}-packages?h=qt" | \
            grep -vE '(^#|^$)' >> pkglist
    done

    grep -q qt5-webkit pkglist || echo qt5-webkit >> pkglist
    grep -q qt5-mqtt pkglist || echo qt5-mqtt >> pkglist
    echo pyqt5 >> pkglist
    echo pyqt5-webengine >> pkglist
    sed -i '/qt5-doc/d' pkglist
    sed -i '/qt5-examples/d' pkglist

    mapfile -t packages < pkglist
else
    packages=$@
fi

rm -rf packages "${packages[@]}"

for pkg in "${packages[@]}"; do
    echo "Downloading $pkg..."
    git clone git://projects.archlinux.org/svntogit/packages.git \
        --branch=packages/$pkg --single-branch -q || exit 1
    cp -R packages/trunk $pkg
    rm -rf packages
done
