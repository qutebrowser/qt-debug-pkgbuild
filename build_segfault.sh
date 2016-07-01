#!/bin/bash

set -e
dir="$PWD"
qtbuilddir="~/docker/archlinux-qtbuild"

if [[ $1 == --temp ]]; then
    outdir=$PWD/out
    temp=1
    shift 1
else
    outdir=/srv/http/qutebrowser/qt-debug/x86_64
    temp=0
fi

ssh segfault mkdir -p "$qtbuilddir"
rsync -avPh --files-from=<(git ls-files) . segfault:"$qtbuilddir"
ssh segfault "$qtbuilddir/build_segfault_docker.sh" "$@"

if (( $# > 0 )); then
    packages=$@
else
    packages=$(cat pkglist)
fi

for pkg in $packages; do
    rm -f "$outdir"/$pkg-*
    rsync -avPh segfault:"$qtbuilddir/out/*${pkg}-*" "$outdir"

    if (( ! temp )); then
        for f in "$outdir"/*$pkg-*.pkg.tar.xz; do
            gpg --detach-sign --default-key 0xE80A0C82 "$f"
        done

        repo-add "$outdir/qt-debug.db.tar.gz" "$outdir"/*"$pkg"-*.pkg.tar.xz
    fi
done

cd "$dir"
