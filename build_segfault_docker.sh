#!/bin/bash
mkdir -p ~/docker/archlinux-qtbuild 2>/dev/null
cd ~/docker/archlinux-qtbuild

mkdir out 2>/dev/null
chmod 777 out

rm out/*
docker build --no-cache -t archlinux-qtbuild . || exit 1
time docker run --privileged -i --tmpfs=/tmp:size=100G,exec -v $PWD/out:/out -e "PACKAGES=$*" archlinux-qtbuild
