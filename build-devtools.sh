#!/bin/bash
set -x

PACKAGES=$(cat pkglist)
pkgdest="$PWD/out"
for pkg in $PACKAGES; do
	include=" "
	skip=0
	for donepkg in "$PWD"/out/*; do
		include+="-I $donepkg "
	done
	(cd "$pkg"
	for made in $(makepkg --packagelist); do
		test -f "$pkgdest/${made##*/}" && skip=1
	done
	((skip)) && continue || extra-x86_64-build -- -c "$include"
	mv "$(makepkg --packagelist)" "$pkgdest")
done
