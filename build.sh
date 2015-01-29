#!/bin/bash

set -e
dir="$PWD"
outdir=/srv/http/qutebrowser/qt-debug

export DEBUG_CFLAGS='-ggdb3 -fvar-tracking-assignments -Og'
export DEBUG_CXXFLAGS='-ggdb3 -fvar-tracking-assignments -Og'
export PKGEXT='.pkg.tar.xz'
export BUILDENV=(!distcc color ccache check sign)
export GPGKEY="0xE80A0C82"

cd "$dir/qt5"
rm *.pkg.tar* || true
rm -r src/python2-path || true
makepkg -si
cp *.pkg.tar.xz "$outdir"

cd "$dir/pyqt5"
rm *.pkg.tar* || true
makepkg -si
cp *.pkg.tar.xz "$outdir"

repo-add "$outdir/qt-debug.db.tar.gz" "$outdir"/*.pkg.tar.xz

cd "$dir"
