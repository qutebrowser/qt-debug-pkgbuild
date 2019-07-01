#!/bin/bash5

set -e -x

fail() {
    echo "!!! Error occcurred while patching, aborting!" >&2
    exit 1
}

patch_qt() {
    for pkg in "$@"; do
        [[ $pkg != *qt5-* ]] && continue
        [[ $pkg == qt5-base ]] && continue

        if grep -q _orig_pkgname $pkg/PKGBUILD; then
            echo "$pkg was already rewritten?"
            exit 1
        fi

        # Adjust package names
        sed -i 's|^pkgname=.*|&-debug\n_orig_pkgname=${pkgname/-debug/}|' $pkg/PKGBUILD
        sed -i '/^_pkgfqn=/s/pkgname/_orig_pkgname/g' $pkg/PKGBUILD

        # update conflicts/replaces for qt5-webkit-ng
        sed -i 's/conflicts=(qt5-webkit-ng)/conflicts=(qt5-webkit-ng qt5-webkit-ng-debug)/' $pkg/PKGBUILD
        sed -i 's/replaces=(qt5-webkit-ng)/replaces=(qt5-webkit-ng qt5-webkit-ng-debug)/' $pkg/PKGBUILD

        # add conflicts-entry for non-debug package
        if grep -q '^conflicts=' $pkg/PKGBUILD; then
            sed -i 's|^conflicts=(\(.*\))|conflicts=(\1 '\'$pkg\'')|' $pkg/PKGBUILD
        else
            grep -q '^depends=' $pkg/PKGBUILD || fail
            sed -i '/^depends=/iconflicts=('\'$pkg\'')' $pkg/PKGBUILD
        fi

        # add provides-entry for non-debug package
        if grep -q provides $pkg/PKGBUILD; then
            sed -i 's/provides=(\(.*\))/provides=("'$pkg'=$pkgver" \1)/' $pkg/PKGBUILD
        else
            grep -q '^depends=' $pkg/PKGBUILD || fail
            sed -i '/^depends=/iprovides=("'$pkg'=$pkgver")' $pkg/PKGBUILD
        fi

        # add debug options
        sed -i '/^provides=/aoptions=("debug" "!strip")' $pkg/PKGBUILD
        grep -q options $pkg/PKGBUILD || fail
    done
}

patch_qt_base() {
    if grep -q _orig_pkgbase qt5-base/PKGBUILD; then
        echo "qt5-base was already rewritten?"
        exit 1
    fi

    # add debug switch
    sed -i 's/-reduce-relocations/& \\\n    -force-debug-info/' qt5-base/PKGBUILD
    grep -q -- -force-debug-info qt5-base/PKGBUILD || fail

    # adjust package names
    sed -i '/^pkgname=.*/s/\([ )]\)/-debug&/g' qt5-base/PKGBUILD
    sed -i 's/\${pkgbase/${_orig_pkgbase/g' qt5-base/PKGBUILD
    sed -i 's|^pkgbase=.*|&-debug\n_orig_pkgbase=${pkgbase/-debug/}|' qt5-base/PKGBUILD

    # add provides/conflicts/options sections to package functions
    line1='  provides=("qt5-base=$pkgver")'
    line2='  conflicts+=("qt5-base")'
    line3='  options=("debug" "!strip")'
    sed -i "/^package_qt5-base/a\\$line1\\n$line2\\n$line3" qt5-base/PKGBUILD
    sed -i 's/package_qt5-base/&-debug/' qt5-base/PKGBUILD
    grep -q package_qt5-base-debug qt5-base/PKGBUILD || fail
    grep -q "$line1" qt5-base/PKGBUILD || fail
    grep -q "$line2" qt5-base/PKGBUILD || fail
    grep -q "$line3" qt5-base/PKGBUILD || fail

    line1='  provides=("qt5-xcb-private-headers=$pkgver")'
    line2='  conflicts+=("qt5-xcb-private-headers")'
    sed -i "/^package_qt5-xcb-private-headers/a\\$line1\\n$line2\\n$line3" qt5-base/PKGBUILD
    sed -i 's/package_qt5-xcb-private-headers/&-debug/' qt5-base/PKGBUILD
    grep -q package_qt5-xcb-private-headers-debug qt5-base/PKGBUILD || fail
    grep -q "$line1" qt5-base/PKGBUILD || fail
    grep -q "$line2" qt5-base/PKGBUILD || fail
}

patch_pyqt() {
    pkg=$1
    # replace all pyqt5 references
    sed -i "s/\\($pkg[a-z0-9-]*\\)/\\1-debug/g" $pkg/PKGBUILD
    sed -i 's/-debug\.so/\.so/g' $pkg/PKGBUILD
    # add debug options
    sed -i '/^license=/aoptions=("debug" "!strip")' $pkg/PKGBUILD
    grep -q options $pkg/PKGBUILD || fail
    # fix up sip name
    sed -i "s/\\(python2\\?-sip-$pkg\\)-debug/\\1/g" $pkg/PKGBUILD
    grep -qF python-sip-$pkg-debug $pkg/PKGBUILD && fail
    grep -qF python2-sip-$pkg-debug $pkg/PKGBUILD && fail

    # add provides/conflicts/options sections to package functions
    line1="  provides=(\"$pkg-common=\$pkgver\")"
    line2="  conflicts=(\"$pkg-common\")"
    line3='  options=("debug" "!strip")'
    sed -i "/^package_$pkg-common-debug/a\\$line1\\n$line2\\n$line3" $pkg/PKGBUILD
    grep -q "$line1" $pkg/PKGBUILD || fail
    grep -q "$line2" $pkg/PKGBUILD || fail
    grep -q "$line3" $pkg/PKGBUILD || fail

    line1="  provides=(\"python-$pkg=\$pkgver\")"
    line2="  conflicts=(\"python-$pkg\")"
    sed -i "/^package_python-$pkg-debug/a\\$line1\\n$line2\\n$line3" $pkg/PKGBUILD
    grep -q "$line1" $pkg/PKGBUILD || fail
    grep -q "$line2" $pkg/PKGBUILD || fail

    line1="  provides=(\"python2-$pkg=\$pkgver\")"
    line2="  conflicts=(\"python2-$pkg\")"
    sed -i "/^package_python2-$pkg-debug/a\\$line1\\n$line2\\n$line3" $pkg/PKGBUILD
    grep -q "$line1" $pkg/PKGBUILD || fail
    grep -q "$line2" $pkg/PKGBUILD || fail

    # add debug switch
    if [[ $pkg == pyqt5 ]]; then
        sed -i 's|--qsci-api|& \\\n    --debug|' $pkg/PKGBUILD
        grep -q -- --debug $pkg/PKGBUILD || fail
    fi

    # fix up URL
    if [[ $pkg == pyqtwebengine ]]; then
        sed -i 's|software/pyqtwebengine-debug/intro|software/pyqtwebengine/intro|' $pkg/PKGBUILD
        grep -q -- software/pyqtwebengine-debug/intro $pkg/PKGBUILD && fail
    fi
}

if (( $# == 0 )); then
    packages=(qt5-* pyqt5 pyqtwebengine)
else
    packages="$@"
fi

patch_qt "${packages[@]}"
[[ "${packages[@]}" == *qt5-base* ]] && patch_qt_base
[[ "${packages[@]}" == *pyqt5* ]] && patch_pyqt pyqt5
[[ "${packages[@]}" == *pyqtwebengine* ]] && patch_pyqt pyqtwebengine
