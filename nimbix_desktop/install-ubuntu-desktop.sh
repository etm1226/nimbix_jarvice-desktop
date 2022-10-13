#!/bin/bash -ex

ARCH=$(arch)
source /etc/os-release

# Adding a safe download backup since SourceForge goes offline frequently
VGL64VER=2.6.5
#VGL64="https://downloads.sourceforge.net/project/virtualgl/$VGL64VER/virtualgl_${VGL64VER}_amd64.deb"
VGL64="https://storage.googleapis.com/app_archive/virtualgl/virtualgl_${VGL64VER}_amd64.deb"
dirname=$(dirname $0)

export DEBIAN_FRONTEND=noninteractive
apt-get -y update

PKGS="wget gnome-icon-theme software-properties-common \
        humanity-icon-theme tango-icon-theme xfce4 xfce4-terminal \
        fonts-freefont-ttf xfonts-base xfonts-100dpi xfonts-75dpi x11-apps \
        xfonts-scalable xauth firefox ristretto mesa-utils init-system-helpers \
        libxcb1 libxcb-keysyms1 libxcb-util1 librtmp1 python3-numpy \
        gir1.2-gtk-3.0 libxv1 libglu1-mesa dbus-x11"
if [ "$VERSION_ID" == "22.04" ]; then
    PKGS+=" libxtst6"
fi

apt-get -y install $PKGS $RIS
apt-get -y remove light-locker

if [[ "$ARCH" != "x86_64" ]]; then
    echo "non-x86_64 has no VirtualGL"
else
    cd /tmp
    wget --content-disposition "$VGL64"
    dpkg --install virtualgl*.deb || apt-get -f install
    rm -f virtualgl*.deb
fi

PY2=$(python -V 2>&1 |grep "^Python 2" || true)
if [[ -n "$PY2" ]]; then
    # this clobbers py3 only, so do it only if we have py2
    apt-get -y install python-pip libmagickwand-dev python-gtk2 python-gnome2 python-numpy $RIS
    # Wand is used for screenshots
    pip install Wand
fi

apt-get clean

. $dirname/postinstall-desktop.sh
