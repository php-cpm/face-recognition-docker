#!/bin/sh

#refer https://www.freedesktop.org/software/systemd/man/os-release.html
test -e /etc/os-release && os_release='/etc/os-release' || os_release='/usr/lib/os-release'

OS=`grep '^ID=' ${os_release} |awk -F '=' '{print $2}' 2>/dev/null`
PKG=""

#refer https://www.freedesktop.org/software/systemd/man/os-release.html
test -e /sbin/apk && is_apk=1 || is_apk=0
test -e /usr/bin/apt && is_apt=1 || is_apt=0
test -e /usr/bin/yum && is_yum=1 || is_yum=0

if [ $is_yum = 1 ]; then
  PKG="yum"
elif [ $is_apt = 1 ]; then
  PKG="apt"
elif [ $is_apk = 1 ]; then
  PKG="apk"
fi

echo "using "$PKG" in "$OS

if [ $PKG = "apk" ]; then

  sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
elif [ $PKG = "yum" -a $OS = "centos" ]; then
  sed -e 's|^mirrorlist=|#mirrorlist=|g' \
         -e 's|^#baseurl=http://mirror.centos.org|baseurl=https://mirrors.tuna.tsinghua.edu.cn|g' \
         -i.bak \
         /etc/yum.repos.d/CentOS-*.repo
elif [ $PKG = "apt" -a $OS = "ubuntu" ]; then
  sed -i "s/mirrors.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/" /etc/apt/sources.list
  sed -i "s/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/" /etc/apt/sources.list
elif [ $PKG = "apt" ]; then
  sed -i 's/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list
  sed -i 's|security.debian.org/debian-security|mirrors.tuna.tsinghua.edu.cn/debian-security|g' /etc/apt/sources.list
else
  echo "fail to find package manager"
fi
