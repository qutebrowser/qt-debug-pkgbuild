#!/bin/bash

set -e -x

fail() {
    echo "!!! Error occcurred while patching, aborting!" >&2
    exit 1
}

### First handle all qt5-* packages
for pkg in qt5-*; do
    if grep -q _orig_pkgname $pkg/PKGBUILD; then
        echo "$pkg was already rewritten?"
        exit 1
    fi

    # replace all qt5-* references
    sed -i 's/\(\Wqt5-[a-z0-9-]*\)/\1-debug/g' $pkg/PKGBUILD

    # Use old pkgname where needed
    sed -i '/^pkgname=/a_orig_pkgname=${pkgname/-debug/}' $pkg/PKGBUILD
    sed -i '/^_pkgfqn=/s/pkgname/_orig_pkgname/g' $pkg/PKGBUILD
    sed -i 's/-debug\.patch/\.patch/g' $pkg/PKGBUILD

    # add conflicts-entry for non-debug package
    if grep -q conflicts $pkg/PKGBUILD; then
        sed -i 's|conflicts=(\(.*\))|conflicts=(\1 '\'$pkg\'')|' $pkg/PKGBUILD
    else
        grep -q _pkgfqn= $pkg/PKGBUILD || fail
        sed -i '/^_pkgfqn=/aconflicts=('\'$pkg\'')' $pkg/PKGBUILD
    fi

    # add provides-entry for non-debug package
    grep -q provides $pkg/PKGBUILD && fail
    sed -i '/^_pkgfqn=/aprovides=("'$pkg'==$pkgver")' $pkg/PKGBUILD
    grep -q provides $pkg/PKGBUILD || fail

    # add debug options
    sed -i '/^provides=/aoptions=("debug" "!strip")' $pkg/PKGBUILD
    grep -q options $pkg/PKGBUILD || fail
done

### qt5-base patches
sed -i 's/${SSE2}/& \\\n    -force-debug-info/' qt5-base/PKGBUILD
grep -q -- -force-debug-info qt5-base/PKGBUILD || fail

### pyqt5 patches
# replace all qt5 references
sed -i 's/\(\Wqt5-[a-z0-9-]*\)/\1-debug/g' pyqt5/PKGBUILD
# replace all pyqt5 references
sed -i 's/\(pyqt5[a-z0-9-]*\)/\1-debug/g' pyqt5/PKGBUILD
sed -i 's/-debug\.so/\.so/g' pyqt5/PKGBUILD
# add debug options
sed -i '/^md5sums=/aoptions=("debug" "!strip")' pyqt5/PKGBUILD
grep -q options $pkg/PKGBUILD || fail
# add debug switch
sed -i 's|-q /usr/bin/qmake-qt5|& \\\n    --debug|' pyqt5/PKGBUILD
grep -q -- --debug pyqt5/PKGBUILD || fail

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
