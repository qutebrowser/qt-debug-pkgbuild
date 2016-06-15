#!/bin/bash

rm -rf pkglist qt5-* pyqt5

### Pinned package list versions as the one in the HEAD is Qt 5.7.0

# for name in dep opt; do
#     echo "Downloading $name package list..."
#     wget -q -O- "https://projects.archlinux.org/kde-build.git/plain/qt-${name}-packages?h=qt" | \
#         grep -vE '(^#|^$)' >> pkglist
# done

echo "Downloading dep package list..."
wget -q -O- "https://git.archlinux.org/kde-build.git/plain/qt-dep-packages?h=qt&id=70112a2a768b578bfcbe6133892be0cca5e18dc2" | \
    grep -vE '(^#|^$)' >> pkglist

echo "Downloading opt package list..."
wget -q -O- "https://git.archlinux.org/kde-build.git/plain/qt-opt-packages?h=qt&id=1343eb21a38c49a32970109c0d9b88a5c5db227e" | \
    grep -vE '(^#|^$)' >> pkglist

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
