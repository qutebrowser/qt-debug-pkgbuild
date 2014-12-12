#!/bin/bash
rm -rf qt5 pyqt5
rsync -rv rsync.archlinux.org::abs/$(uname -m)/extra/{py,}qt5 .
