FROM base/archlinux
MAINTAINER Florian Bruhin <me@the-compiler.org>

RUN echo 'Server = http://mirror.de.leaseweb.net/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist
RUN pacman-key --init && pacman-key --populate archlinux && pacman -Sy --noconfirm archlinux-keyring
RUN pacman -Suy --noconfirm pacman | cat && pacman-db-upgrade
RUN pacman -Suy --noconfirm --needed \
    git \
    base-devel \
    # qt5-base makedepends
    mtdev \
    libfbclient \
    libmariadbclient \
    sqlite \
    unixodbc \
    postgresql-libs \
    alsa-lib \
    gst-plugins-base-libs \
    gtk2 \
    libpulse \
    cups \
    freetds \
    # qt5-connectivity makedepends
    bluez-libs \
    # qt5-declarative makedepends
    python2 \
    # qt5-webengine makedepends
    python2 \
    git \
    gperf \
    # qt5-webkit makepends
    ruby \
    gperf \
    python2 \
    # pyqt5 makedepends
    python-opengl \
    python2-opengl \
    python2-dbus \
    python-dbus \
    # to have a running Qt already
    qt5 \
    python-pyqt5 \
    python2-pyqt5 \
    # To avoid "GPGME error: Inappropriate ioctl for device"
    | cat
RUN sed -i 's/#MAKEFLAGS=.*/MAKEFLAGS="-j$(nproc)"/' /etc/makepkg.conf && \
    sed -i 's|#BUILDDIR=.*|BUILDDIR="/tmp/makepkg"|' /etc/makepkg.conf && \
    sed -i 's|#PKGDEST=.*|PKGDEST="/out"|' /etc/makepkg.conf && \
    sed -i 's|COMPRESSXZ=.*|COMPRESSXZ=(xz -c -z --threads=0 -)|' /etc/makepkg.conf


RUN mkdir /out && \
    echo 'ALL ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers && \
    useradd user -u 1001 && \
    mkdir /home/user

COPY . /home/user

RUN chown -R user:users /home/user && \
    chown user:users /out

USER user
WORKDIR /home/user

CMD ./docker_entrypoint.sh
