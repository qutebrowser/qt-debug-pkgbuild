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
    sed -i 's/\(qt5-[a-z0-9-]*\)/\1-debug/g' $pkg/PKGBUILD

    # Use old pkgname where needed
    sed -i '/^pkgname=/a_orig_pkgname=${pkgname/-debug/}' $pkg/PKGBUILD
    sed -i '/^_pkgfqn=/s/pkgname/_orig_pkgname/g' $pkg/PKGBUILD
    sed -i 's/-debug\.patch/\.patch/g' $pkg/PKGBUILD

    # add conflicts-entry for non-debug package
    if grep -q conflicts $pkg/PKGBUILD; then
        sed -i 's|conflicts=(\(.*\))|conflicts=(\1 '\'$pkg\'')|' $pkg/PKGBUILD
    else
        grep -q depends= $pkg/PKGBUILD || fail
        sed -i '/^depends=/aconflicts=('\'$pkg\'')' $pkg/PKGBUILD
    fi

    # add provides-entry for non-debug package
    grep -q provides $pkg/PKGBUILD && fail
    sed -i '/^depends=/aprovides=("'$pkg'==$pkgver")' $pkg/PKGBUILD
    grep -q provides $pkg/PKGBUILD || fail

    # add debug options
    sed -i '/^provides=/aoptions=("debug" "!strip")' $pkg/PKGBUILD
    grep -q options $pkg/PKGBUILD || fail
done

#### qt5-base patches
sed -i 's/${SSE2}/& \\\n    -force-debug-info/' qt5-base/PKGBUILD
grep -q -- -force-debug-info qt5-base/PKGBUILD || fail
