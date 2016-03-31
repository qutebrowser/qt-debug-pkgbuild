#!/bin/bash

set -e

for pkg in qt5-*; do
    # pkgname
    sed -i 's|pkgname=\(.*\)|pkgname=\1-debug\n_orig_pkgname=${pkgname/-debug/}|' $pkg/PKGBUILD
    sed -i 's|_pkgfqn="${pkgname/5-/}-\(.*\)"|_pkgfqn="${_orig_pkgname/5-/}-\1"|' $pkg/PKGBUILD

    # conflicts
    grep -q conflicts $pkg/PKGBUILD || exit 1
    sed -i 's|conflicts=(\(.*\))|conflicts=(\1 '\'$pkg\'')|' $pkg/PKGBUILD

    # provides
    grep -q provides $pkg/PKGBUILD && exit 1
    sed -i '/^conflicts=/aprovides=("'$pkg'==$pkgver")' $pkg/PKGBUILD
    grep -q provides $pkg/PKGBUILD || exit 1

    # options
    sed -i '/^provides=/aoptions=("debug" "!strip")' $pkg/PKGBUILD
    grep -q options $pkg/PKGBUILD || exit 1
done

# -force-debug-info
sed -i 's/${SSE2}/& \\\n    -force-debug-info/' qt5-base/PKGBUILD
