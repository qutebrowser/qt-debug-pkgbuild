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
    # qt5-base
    libjpeg-turbo \
    xcb-util-keysyms \
    libgl \
    fontconfig \
    xcb-util-wm \
    libxrender \
    libxi \
    sqlite \
    xcb-util-image \
    icu \
    qtchooser \
    tslib \
    libinput \
    libsm \
    libxkbcommon-x11 \
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
    # qt5-declarative makedepends
    python2 \
    # qt5-imageformats
    libtiff \
    jasper \
    # qt5-multimedia
    gst-plugins-base-libs \
    libpulse \
    openal \
    # qt5-wayland
    libxcomposite \
    libxkbcommon \
    # qt5-webengine
    libxcomposite \
    libxrandr \
    libxtst \
    libxcursor \
    libpulse \
    pciutils \
    libxss \
    libvpx \
    opus \
    libevent \
    libsrtp \
    jsonpp \
    libwebp \
    snappy \
    minizip \
    nss \
    libxml2 \
    libxslt \
    # qt5-webengine makedepends
    python2 \
    git \
    gperf \
    # qt5-webkit
    libwebp \
    libxslt \
    libxcomposite \
    gst-plugins-base \
    # qt5-webkit makepends
    ruby \
    gperf \
    python2 \
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

CMD while read pkg; do \
        cd ~/$pkg && \
        makepkg -i --noconfirm \
        ; \
    done < pkglist
