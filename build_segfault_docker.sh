#!/bin/bash
mkdir -p ~/docker/archlinux-qtbuild 2>/dev/null
cd ~/docker/archlinux-qtbuild

mkdir out 2>/dev/null
chmod 777 out

rm out/*
docker build -t archlinux-qtbuild .
time docker run -i --tmpfs=/tmp:size=100G -v $PWD/out:/out archlinux-qtbuild
