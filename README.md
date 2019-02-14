# qt-debug-pkgbuild

Archlinux PKGBUILDs for Qt5/PyQt5 with debugging enabled.

## A note on branches

* *upstream*: The vanilla Archlinux upstream packages.
* *master*: Based on *upstream*, adds debugging symbols.

## Precompiled binary packages

Binary packages for the *master* branch are available as an unofficial
Archlinux repo. See [the qutebrowser documentation](https://github.com/The-Compiler/qutebrowser/blob/master/doc/stacktrace.asciidoc#archlinux)
for details.

## Workflow

Until Qt 5.7, the patched PKGBUILDs lived in the *master* branch, and the
*upstream* branch (with the vanilla Archlinux PKGBUILDs) got merged into
*upstream* after updating. However, this caused frequent merge conflicts as the
patched lines are close to the version number.

Since Qt 5.7, there are no merges anymore - instead, the updated upstream
PKGBUILDs live in the upstream branch, and patching is automated using
`patch.sh`.

Here is how an update looks:

## Update upstream

- `git checkout upstream`
- `bash update.sh`
- `git status`, add new files
- `git diff`, review upstream changes
- `git commit -am "Update to Qt 5.x.y"
- `git push`

## Update patched PKGBUILDs

- `git checkout master`
- `git rm -r qt5-* pyqt*`
- `git checkout upstream -- qt5-\* pyqt\* pkglist`
- `git reset HEAD .` (unstage all changes)
- `bash patch.sh`
- `git status`, add/delete files
- `git diff --staged`, review
- `git commit`
- Add new makedepends in `Dockerfile` if needed
- `git commit`
- `git push`

## Rebuild

- `bash build_segfault.sh`
