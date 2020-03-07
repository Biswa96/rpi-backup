# This shell script is part of the rpi-backup repository.
# Build_RPi4_EDK2_Firmware.sh: shell script to build EDK2 UEFI Firmware for Raspberry Pi4.
# Inspired from github.com/pftf/RPi4 repository.

#!/bin/sh

#
# 1. Update and install required packages
#
sudo apt update
sudo apt upgrade
sudo apt install \
build-essential \
acpica-tools \
gcc-aarch64-linux-gnu \
uuid-dev \
python3-distutils

#
# 2. Clone required git repositories
#
git clone --depth=1 https://github.com/tianocore/edk2.git
git clone --depth=1 https://github.com/tianocore/edk2-platforms.git
git clone --depth=1 https://github.com/tianocore/edk2-non-osi.git

cd edk2/
git submodule update --init --recursive
cd ../

#
# 3. Download required boot related files
#
LINK="https://github.com/raspberrypi/firmware/raw/master/boot"
wget $LINK/fixup4.dat
wget $LINK/start4.elf
wget $LINK/bcm2711-rpi-4-b.dtb
wget $LINK/overlays/miniuart-bt.dtbo
mkdir overlays
mv miniuart-bt.dtbo overlays

#
# 4. Compile base tools and prepare building environment variables
#
make -s -j$(nproc) -C edk2/BaseTools
export GCC5_AARCH64_PREFIX=aarch64-linux-gnu-
export WORKSPACE=$PWD
export PACKAGES_PATH=$WORKSPACE/edk2:$WORKSPACE/edk2-platforms:$WORKSPACE/edk2-non-osi
source edk2/edksetup.sh

#
# 5. Compile the actual EFI file
#
build \
--quiet \
--arch=AARCH64 \
--tagname=GCC5 \
--buildtarget=RELEASE \
-D SECURE_BOOT_ENABLE=TRUE \
-D INCLUDE_TFTP_COMMAND=TRUE \
--platform=edk2-platforms/Platform/RaspberryPi/RPi4/RPi4.dsc

#
# 6. Create the tarball for distribution
#
cp Build/RPi4/RELEASE_GCC5/FV/RPI_EFI.fd ./
tar -cpJf ../RPi4_EDK2_Firmware.tar.xz \
RPI_EFI.fd \
bcm2711-rpi-4-b.dtb \
config.txt \
fixup4.dat \
start4.elf \
overlays/miniuart-bt.dtbo
