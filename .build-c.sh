#!/usr/bin/env bash

# OpenWrt CI Builder
# Copyright (C) 2021 @Boos4721(Telegram and Github)  
# Default Settings

export ARCH=amd64
export SUBARCH=amd64
export HOME=/drone
export FORCE_UNSAFE_CONFIGURE=1
export FORCE=1
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime


SETUP() {
apt-get update 
apt-get -y install build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch python3 python2.7 unzip zlib1g-dev lib32gcc1 libc6-dev-i386 subversion flex uglifyjs git-core gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint device-tree-compiler g++-multilib antlr3 gperf wget curl swig rsync    
git config --global user.email 3.1415926535boos@gmail.com
git config --global user.name $id
}

CLONE() {
git clone https://github.com/R619AC-OpenWrt/OpenWrt-Packages package/Boos --depth=1 
wget -O .config https://gitlab.com/$id//openwrt/-/raw/master/.config-c
./scripts/feeds update -a -f
./scripts/feeds install -a -f
}


BUILD() {
make defconfig
BUILD_START=$(date +"%s")
echo " ${Old_Version} Starting first build..."
make download -j$(nproc)
make -j$(nproc) || make -j$(nproc) V=s
BUILD_END=$(date +"%s")
}

UPLOAD() {
mkdir -p ~/UPLOAD && cd ~/src/bin/targets/*/* && mv *.bin *.ubi ~/UPLOAD/      
curl -fsSL git.io/file-transfer | sh
./transfer cow --block 2621440 -s -p 64 --no-progress ~/UPLOAD 2>&1 | tee cowtransfer.log
echo "cat cowtransfer.log | grep https"
}

GITHUB_UPLOAD() {
cd ~/UPLOAD
git init
git remote add origin https://$id:$ss@github.com/$id/updater.git
git checkout -b OpenWrt-Test
git add .
git commit -sm "$(date +"%m%d-%H%S")"
git fetch && git pull origin OpenWrt-Test
git push -u origin OpenWrt-Test    

}

SETUP
CLONE
BUILD
UPLOAD
GITHUB_UPLOAD

DIFF=$(($BUILD_END - $BUILD_START))
echo "Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds"
