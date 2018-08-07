#!/bin/bash

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
            grep -q _pkgfqn= $pkg/PKGBUILD || fail
            sed -i '/^_pkgfqn=/aconflicts=('\'$pkg\'')' $pkg/PKGBUILD
        fi

        # add provides-entry for non-debug package
        if grep -q provides $pkg/PKGBUILD; then
            sed -i 's/provides=(\(.*\))/provides=("'$pkg'=$pkgver" \1)/' $pkg/PKGBUILD
        else
            sed -i '/^_pkgfqn=/aprovides=("'$pkg'=$pkgver")' $pkg/PKGBUILD
        fi

        # add debug options
        sed -i '/^provides=/aoptions=("debug" "!strip")' $pkg/PKGBUILD
        grep -q options $pkg/PKGBUILD || fail
    done
}

patch_qt_base() {
    if grep -q _orig_pkgbase $pkg/PKGBUILD; then
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
    # replace all pyqt5 references
    sed -i 's/\(pyqt5[a-z0-9-]*\)/\1-debug/g' pyqt5/PKGBUILD
    sed -i 's/-debug\.so/\.so/g' pyqt5/PKGBUILD
    # add debug options
    sed -i '/^license=/aoptions=("debug" "!strip")' pyqt5/PKGBUILD
    grep -q options $pkg/PKGBUILD || fail
    # add debug switch
    sed -i 's|--qsci-api|& \\\n    --debug|' pyqt5/PKGBUILD
    grep -q -- --debug pyqt5/PKGBUILD || fail
    # fix up sip name
    sed -i 's/\(python2\?-sip-pyqt5\)-debug/\1/g' pyqt5/PKGBUILD
    grep -qF python-sip-pyqt5-debug pyqt5/PKGBUILD && fail
    grep -qF python2-sip-pyqt5-debug pyqt5/PKGBUILD && fail

    # add provides/conflicts/options sections to package functions
    line1='  provides=("pyqt5-common=$pkgver")'
    line2='  conflicts=("pyqt5-common")'
    line3='  options=("debug" "!strip")'
    sed -i "/^package_pyqt5-common-debug/a\\$line1\\n$line2\\n$line3" pyqt5/PKGBUILD
    grep -q "$line1" pyqt5/PKGBUILD || fail
    grep -q "$line2" pyqt5/PKGBUILD || fail
    grep -q "$line3" pyqt5/PKGBUILD || fail

    line1='  provides=("python-pyqt5=$pkgver")'
    line2='  conflicts=("python-pyqt5")'
    sed -i "/^package_python-pyqt5-debug/a\\$line1\\n$line2\\n$line3" pyqt5/PKGBUILD
    grep -q "$line1" pyqt5/PKGBUILD || fail
    grep -q "$line2" pyqt5/PKGBUILD || fail

    line1='  provides=("python2-pyqt5=$pkgver")'
    line2='  conflicts=("python2-pyqt5")'
    sed -i "/^package_python2-pyqt5-debug/a\\$line1\\n$line2\\n$line3" pyqt5/PKGBUILD
    grep -q "$line1" pyqt5/PKGBUILD || fail
    grep -q "$line2" pyqt5/PKGBUILD || fail
}

if (( $# == 0 )); then
    packages=(qt5-* pyqt5)
else
    packages="$@"
fi

patch_qt "${packages[@]}"
[[ "${packages[@]}" == *qt5-base* ]] && patch_qt_base
[[ "${packages[@]}" == *pyqt5* ]] && patch_pyqt
