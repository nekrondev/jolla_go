#!/bin/bash
#
# GO runtime installation (quick and dirty)
# (C) 2015 Nekron

# Kill any running zypper processes before launching setup
sudo pkill -9 zypper

set -e

# Set your HTTP(S) proxy here if you are behind a firewall
HTTP_PROXY=
HTTPS_PROXY=
export http_proxy=$HTTP_PROXY
export https_proxy=$HTTPS_PROXY

GREEN='\033[0;32m'
NOCOLORLF='\033[0m\n'

# Intro
printf "\n${GREEN}Jolla MerSDK GO 1.4.2 runtime installer by Nekron\n"
printf "=================================================\n"
printf "This installer will prepare GO runtime on a vanilla Jolla-1.1.6.27 SDK\n"
printf "After installation has been completed you will find GO runtime installed into your mersdk home's root directory.\n"
printf "Compilation of Jolla applications for emulator will be done from MerSDK and not SailfishOS-i486 target, i.e.\n"
printf "you can build your applications without sb2 -t SailfishOS-i486 command. However if you finally cross-compile to\n"
printf "ARM target you have to call sb2 -t SailfishOS-armv7hl ~/go/bin/linux_arm/go.\n\n"
printf "The following changes will be applied to MerSDK:\n"
printf " - Installation of QEMU 2.3.0 and changing SailfishOS-armv7hl target to use new qemu-arm\n"
printf " - Modifying .bashrc for GOPATH, GOROOT and go binary to \$PATH setup\n\n"
printf "The following patches will be applied to GO runtime:\n"
printf " - Modified errorcounter to build go binary even if there are unknown symbols message printed\n"
printf " - Modified header file os_linux.h NSIG to make go ARM binary not to crash launching from qemu\n\n"
printf "The following patches will be applied to GO QML package v1:\n"
printf " - Removed shared library dependency for QWidget (or else harbour rpm validator will fail)\n"
printf " - Changed QApplication to QGuiApplication (needed for removing QWidget dependency)\n"
printf " - Added new CPP method newTranslator() to install i18n files for QML application\n"
printf " - Added GO QML func Translator(path_to_i18n_directory) to load qml_<system locale>.qm translation file\n"
printf " - Added new QDateTime packing/unpacking for GO runtime time.Time types\n"
printf " - Added CloseEventFilter for QQuickWindow to signal closing to Silica application\n"
printf " - Disabled original hookWindowHidded() trigger since coverview of Silica QML would close application\n\n"
read -p "Press [ENTER] to accept the given modifications and continue installation ..."

# Creating temp directory for downloads
cd
if [ -d "~/downloads" ]; then
    mkdir downloads
else
    sudo rm -rf ~/downloads
    mkdir downloads
fi
cd downloads

# Updating QEMU for MerSDK as GO runtime for ARM target will only work with an updated QEMU or else lots of segfaults!
printf "${GREEN}Downloading QEMU 2.3.0 ...${NOCOLORLF}"
curl -O -L http://wiki.qemu.org/download/qemu-2.3.0.tar.bz2
bunzip2 qemu-2.3.0.tar.bz2
tar xfv qemu-2.3.0.tar
cd qemu-2.3.0
printf "${GREEN}Installing additional dependencies for QEMU compilation ...${NOCOLORLF}"
sudo http_proxy=$HTTP_PROXY https_proxy=$HTTPS_PROXY zypper -n install libtool zlib-devel glib2-devel
printf "${GREEN}Compiling and installing QEMU 2.3.0 ...${NOCOLORLF}"
./configure --target-list=arm-softmmu,arm-linux-user
make & sudo make install
printf "${GREEN}Reconfigure SB2 ARM target for new QEMU ...${NOCOLORLF}"
cd /srv/mer/targets/SailfishOS-armv7hl/
sb2-init -L --sysroot=/ -C --sysroot=/ -c /usr/local/bin/qemu-arm -m sdk-build -n -N -t / SailfishOS-armv7hl /opt/cross/bin/armv7hl-meego-linux-gnueabi-gcc

# Creating GO runtime for MerSDK and ARM
cd ~/downloads
printf "${GREEN}Downloading GO 1.4.2 sources ...${NOCOLORLF}"
curl -O -L https://storage.googleapis.com/golang/go1.4.2.src.tar.gz
tar xfvz go1.4.2.src.tar.gz -C ~/
export GOPATH=~/
export GOROOT=~/go
printf "${GREEN}Applying GO MerSDK patch to fix bootstrap and qemu issues on Linaro ...${NOCOLORLF}"
cd
patch -p3 < ~/go1.4.2_mersdk.patch
printf "${GREEN}Compiling GO for MERSDK ...${NOCOLORLF}"
cd ~/go/src
./make.bash
printf "${GREEN}Compiling GO for runtime ARM compilation ...${NOCOLORLF}"
GOOS=linux GOARCH=arm GOARM=7 ./make.bash
printf "${GREEN}Cross compiling GO for ARM target (needed for CGO package cross compilation)...${NOCOLORLF}"
cp ~/go/bin/go ~/go/bin/go_i486
cp ~/go/bin/gofmt ~/go/bin/gofmt_i486
sb2 -O use-global-tmp -t SailfishOS-armv7hl ./make.bash
cp ~/go/bin/go_i486 ~/go/bin/go
cp ~/go/bin/gofmt_i486 ~/go/bin/gofmt
printf "${GREEN}Go runtime for MerSDK and ARM target prepared successfully.${NOCOLORLF}"

# Creating GO QML bindings
printf "${GREEN}Creating GO QML package for Jolla ...\n"
printf "Installing needed MerSDK zypper packages ...${NOCOLORLF}"
sudo http_proxy=$HTTP_PROXY https_proxy=$HTTPS_PROXY zypper -n install qt5-qtcore-devel qt5-qtdeclarative-qtquick-devel qt5-qtopengl-devel
sudo http_proxy=$HTTP_PROXY https_proxy=$HTTPS_PROXY zypper install -t pattern "sailfish-silica-devel"
cd ~/downloads
curl -O -L https://github.com/go-qml/qml/archive/v1.zip
mkdir -p ~/src/gopkg.in
unzip v1.zip 
mv qml-1 ~/src/gopkg.in/qml.v1
printf "${GREEN}Patching GO QML bindings to work with Jolla Silica UI ...${NOCOLORLF}"
cd
patch -p3 < go-qml_jolla.patch
printf "${GREEN}Building and installing GO QML bindings for MerSDK ...${NOCOLORLF}"
cd ~/src/gopkg.in/qml.v1/
~/go/bin/go install
printf "${GREEN}Building and installing GO QML bindings for ARM ...${NOCOLORLF}"
sb2 -O use-global-tmp -t SailfishOS-armv7hl ~/go/bin/linux_arm/go install
printf "${GREEN}Go runtime setup for MerSDK and ARM target completed.${NOCOLORLF}"

# Setting up .bashrc
printf "${GREEN}Adding GOROOT, GOPATH and GO command (i486) to .bashrc ...${NOCOLORLF}"
echo "export GOPATH=~/" >> ~/.bashrc
echo "export GOROOT=~/go" >> ~/.bashrc
echo "export PATH=\$PATH:~/go/bin" >> ~/.bashrc

# Setting up VIM plugins
printf "${GREEN}Installing VIM pathogen plugin ...${NOCOLORLF}"
mkdir -p ~/.vim/autoload ~/.vim/bundle && curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
printf "${GREEN}Installing GO VIM plugin ...${NOCOLORLF}"
git clone https://github.com/fatih/vim-go.git ~/.vim/bundle/vim-go
printf "${GREEN}Installing vim QML syntax plugin ...${NOCOLORLF}"
git clone https://github.com/peterhoeg/vim-qml.git ~/.vim/bundle/vim-qml
echo "execute pathogen#infect()" >> ~/.vimrc
echo "syntax on" >> ~/.vimrc
echo "filetype plugin indent on" >> ~/.vimrc
export PATH=$PATH:~/go/bin

echo "-----------------------------------------------------------------------"
echo "         ,_---~~~~~----._     "    
echo "  _,,_,*^____      _____``*g*\"*, "
echo " / __/ /'     ^.  /      \ ^@q   f"
echo "[  @f | @))    |  | @))   l  0 _/ "
echo " \`/   \~____ / __ \_____/    \   "
echo "  |           _l__l_           I  "
echo "  }          [______]           I "
echo "  ]            | | |            | "
echo "  ]             ~ ~             | "
echo "  |                            |  "
echo "   |                           |  "
echo "-----------------------------------------------------------------------"
echo "Have fun playing around with GO, QML and your Jolla!"
