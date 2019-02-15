FROM thecompiler/archlinux
MAINTAINER Florian Bruhin <me@the-compiler.org>

RUN pacman -Sy --noconfirm archlinux-keyring
RUN pacman -Suy --noconfirm --needed \
    git \
    base-devel \
    # qt5-base makedepends
    libfbclient \
    mariadb-libs \
    sqlite \
    unixodbc \
    postgresql-libs \
    alsa-lib \
    gst-plugins-base-libs \
    gtk3 \
    libpulse \
    cups \
    freetds \
    vulkan-headers \
    # qt5-multimedia makedepends
    gst-plugins-bad \
    # qt5-declarative makedepends
    python2 \
    # qt5-webengine makedepends
    python2 \
    git \
    gperf \
    jsoncpp \
    ninja \
    # qt5-webkit makepends
    cmake \
    ruby \
    gperf \
    python2 \
    # qt5-doc makedepends
    python2 \
    pciutils \
    libxtst \
    libxcursor \
    libxrandr \
    libxss \
    libxcomposite \
    gperf \
    nss \
    clang \
    # qt5-speech makedepends
    flite \
    speech-dispatcher \
    # pyqt5 makedepends
    python-sip-pyqt5 \
    python2-sip-pyqt5 \
    sip \
    python-opengl \
    python2-opengl \
    python2-enum34 \
    python2-dbus \
    python-dbus \
    # to have a running Qt already
    qt5 \
    qt5-webkit \
    python-pyqt5 \
    python2-pyqt5 \
    python-pyqtwebengine \
    python2-pyqtwebengine
RUN sed -i 's/#MAKEFLAGS=.*/MAKEFLAGS="-j$(nproc)"/' /etc/makepkg.conf && \
    sed -i 's|#BUILDDIR=.*|BUILDDIR="/tmp/makepkg"|' /etc/makepkg.conf && \
    sed -i 's|#PKGDEST=.*|PKGDEST="/out"|' /etc/makepkg.conf && \
    sed -i 's|COMPRESSXZ=.*|COMPRESSXZ=(xz -c -z --threads=0 -)|' /etc/makepkg.conf

COPY . /home/user

RUN mkdir /out && \
    chown -R user:users /home/user /out

USER user
WORKDIR /home/user

CMD ./docker_entrypoint.sh
