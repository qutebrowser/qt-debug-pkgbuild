FROM base/archlinux
MAINTAINER Florian Bruhin <me@the-compiler.org>

RUN echo 'Server = http://mirror.de.leaseweb.net/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist
RUN pacman-key --init && pacman-key --populate archlinux && pacman -Sy --noconfirm archlinux-keyring
RUN pacman -Suy --noconfirm --needed \
    git \
    base-devel \
    # To avoid "GPGME error: Inappropriate ioctl for device"
    | cat
RUN pacman-db-upgrade
RUN pacman -Suy --noconfirm --needed \
    # pyqt5
    python-sip \
    python2-sip \
    python-opengl \
    python2-opengl \
    python-dbus \
    python2-dbus \
    # qt5
    libxcb \
    xcb-proto \
    xcb-util \
    xcb-util-image \
    xcb-util-wm \
    xcb-util-keysyms \
    mesa \
    at-spi2-core \
    alsa-lib \
    gst-plugins-base-libs \
    libjpeg-turbo \
    cups \
    libpulse \
    hicolor-icon-theme \
    desktop-file-utils \
    postgresql-libs \
    nss \
    libmariadbclient \
    sqlite \
    unixodbc \
    libfbclient \
    libmng \
    python2 \
    ruby \
    gperf \
    libxslt \
    libxcomposite \
    fontconfig \
    bluez-libs \
    openal \
    gtk2 \
    libxkbcommon-x11 \
    mtdev \
    harfbuzz \
    libwebp \
    leveldb \
    geoclue \
    pciutils \
    libinput \
    yasm \
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

COPY ./qt5 /home/user/qt5
COPY ./pyqt5 /home/user/pyqt5

RUN chown -R user:users /home/user && \
    chown user:users /out

USER user
WORKDIR /home/user

CMD cd ~/qt5 && \
    makepkg -i --noconfirm && \
    cd ~/pyqt5 && \
    makepkg -i --noconfirm
