#!/bin/bash

set -e
dir="$PWD"
outdir=/srv/http/qutebrowser/qt-debug/x86_64
qtbuilddir="~/docker/archlinux-qtbuild"

ssh segfault mkdir -p "$qtbuilddir"
rsync -avPh --files-from=<(git ls-files) . segfault:"$qtbuilddir"
ssh segfault "$qtbuilddir/build_segfault_docker.sh" "$@"
rm "$outdir"/*
rsync -avPh segfault:"$qtbuilddir/out/" "$outdir"

for f in "$outdir"/*.pkg.tar.xz; do
    gpg --detach-sign --default-key 0xE80A0C82 "$f"
done

repo-add "$outdir/qt-debug.db.tar.gz" "$outdir"/*.pkg.tar.xz

cd "$dir"
