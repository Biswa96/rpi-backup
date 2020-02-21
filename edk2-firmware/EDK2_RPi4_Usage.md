# EDK2 Firmware in Raspberry Pi 4

Install operating systems in Raspberry Pi 4 using EDK2 UEFI Firmware.

## Install Debian

### Requirements

These are what I used and already available in my desk but you can use others.

* A working PC with any Debian based Linux distributions installed.
* Debian ARM64 ISO - because the ISO is small and already available.
* 1GB mSD card - where the EDK2 firmware is placed.
* 8GB USB Drive - where the Debian ISO is burned i.e. `dd`
* 32GB USB Drive - where the Debian OS will be installed.

At the time of writing, the EDK2 firmware can not access the mSD card slot so
the USB drive is used to install the OS.

### Procedure

* Execute the [shell script](Build_RPi4_EDK2_Firmware.sh) to build the firmware.
This shell script installs required packages, downloads necessary files, builds
the EDK2 firmware and packages it in a `RPi4_EDK2_Firmware.tar.xz` tarball.

* Extract tarball in mSD card in **MBR** mode and **FAT** formatted partition.

* In PC, copy the Debian ARM64 ISO with `dd` into the USB drive.

* Attach the mSD card and USB drives in Raspberry Pi 4. Install the Debian OS.
To access Internet, I used an Android Device with USB tethering enabled.

* After installation, some files need to be renamed. Because the EDK2 firmware
finds the ARM64 EFI file in `efi/boot/bootaa64.efi` path for removable drive.
First mount mSD card partitions in PC:

```
mkdir /mnt/boot
mount /dev/sdX1 /mnt/boot
mkdir /mnt/root
mount /dev/sdX2 /mnt/root
```

Replace `X` with the USB drive partitions. 1st partition is the EFI and 2nd one
is the root partition.

* Rename `EFI/debian/grubaa64.efi` to `efi/boot/bootaa64.efi`.

```
cd /mnt/boot
mv EFI test; mv test efi
mv efi/debian efi/boot
mv efi/boot/grubaa64.efi efi/boot/bootaa64.efi
```

* Plug in the USB drive in Raspberry Pi4, power it up. The EDK2 firmware will
execute GRUB bootloader. Type these commands to load Linux kernel.

```
set root=(hd0,gpt2)
set prefix=(hd0,gpt2)/boot/grub
normal
```

`(hd0,gpt2)` is the 2nd partition aka. root partition. 

