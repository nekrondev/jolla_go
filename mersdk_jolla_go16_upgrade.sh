#!/bin/bash
#
# GO 1.6 runtime upgrade installation (quick and dirty)
#(C) 2016 Nekron

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
printf "\n${GREEN}Jolla MerSDK GO 1.6 runtime upgrade by Nekron\n"
printf "=====================================================\n"
printf "This installer will upgrade GO 1.4.2 runtime on a vanilla Jolla-1.1.7.28 SDK to GO 1.6\n"
printf "Before executing this script you must have GO 1.4.2 installed on your MerSDK!\n"
printf "If not, please execute mersdk_jolla_go.sh or else upgrade will fail.\n\n"
printf "The following modifications will be applied to GO 1.6 runtime:\n"
printf " - Apply GO 1.6 runtime patch to build go binary on MerSDK even if there are SYM errors\n"
printf " - Apply NSIG patch to make go ARM binary work with QEMU\n\n"
printf "The following modifications will be applied to go-qml package:\n"
printf " - Rebuild and reinstall go-qml package for new GO 1.6 runtime for MerSDK and ARM target\n\n"
read -p "Press [ENTER] to accept the given modifications and continue installation ..."

# Creating temp directory for downloads
cd
if [ -d "~/downloads" ]; then
    mkdir downloads
fi
cd downloads

# Creating GO 1.6 runtime for MerSDK and ARM
printf "${GREEN}Moving GO to GO1.4 needed for bootstrap GO 1.6${NOCOLORLF}\n"
mv ~/go ~/go1.4
cd ~/downloads
printf "${GREEN}Downloading GO 1.6 sources ...${NOCOLORLF}\n"
curl -O -L https://storage.googleapis.com/golang/go1.6.src.tar.gz
tar xfvz go1.6.src.tar.gz -C ~/
export GOPATH=~/
export GOROOT=~/go
printf "${GREEN}Applying GO 1.6 MerSDK patch to fix bootstrap issues on Linaro ...${NOCOLORLF}\n"
cd
patch -p0 < ~/go1.6_mersdk.patch
printf "${GREEN}Compiling GO 1.6 for MerSDK ...${NOCOLORLF}\n"
cd ~/go/src
./make.bash
printf "${GREEN}Compiling GO for runtime ARM compilation ...${NOCOLORLF}\n"
GOOS=linux GOARCH=arm GOARM=7 ./make.bash
printf "${GREEN}Cross compiling GO for ARM target (needed for CGO package cross compilation)...${NOCOLORLF}\n"
cp ~/go/bin/go ~/go/bin/go_i486
cp ~/go/bin/gofmt ~/go/bin/gofmt_i486
sb2 -O use-global-tmp -t SailfishOS-armv7hl ./make.bash
cp ~/go/bin/go_i486 ~/go/bin/go
cp ~/go/bin/gofmt_i486 ~/go/bin/gofmt
printf "${GREEN}Go runtime 1.6 for MerSDK and ARM target prepared successfully.${NOCOLORLF}\n"

printf "${GREEN}Updating GO QML for GO 1.6 MerSDK and ARM target ...${NOCOLORLF}\n"
cd ~/src/gopkg.in/qml.v1
~/go/bin/go install
sb2 -O use-global-tmp -t SailfishOS-armv7hl ~/go/bin/linux_arm/go install

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
echo "Have fun playing around with GO 1.6, QML and your Jolla!"
