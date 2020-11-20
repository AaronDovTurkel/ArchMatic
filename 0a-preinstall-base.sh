#!/usr/bin/env bash
#-------------------------------------------------------------------------
#      _          _    __  __      _   _
#     /_\  _ _ __| |_ |  \/  |__ _| |_(_)__
#    / _ \| '_/ _| ' \| |\/| / _` |  _| / _|
#   /_/ \_\_| \__|_||_|_|  |_\__,_|\__|_\__|
#  Arch Linux Post Install Setup and Config
#-------------------------------------------------------------------------

timedatectl set-ntp true
pacman -S --noconfirm pacman-contrib


echo "-------------------------------------------------"
echo "-------select your disk to format----------------"
echo "-------------------------------------------------"
lsblk
echo "Please enter disk: (example /dev/sda)"
read DISK
echo "--------------------------------------"
echo -e "\nFormatting disk...\n$HR"
echo "--------------------------------------"

# disk prep
sgdisk -Z ${DISK} # zap all on disk
sgdisk -a 2048 -o ${DISK} # new gpt disk 2048 alignment

# create partitions
sgdisk -n 1:0:+500M ${DISK} # partition 1 (UEFI SYS), default start block, 512MB
sgdisk -n 2:0:+30G  ${DISK} # partition 2 (Root), default start, remaining
sgdisk -n 3:0:0     ${DISK} # partition 3 (Home)

# set partition types
sgdisk -t 1:ef00 ${DISK}
sgdisk -t 2:8300 ${DISK}
sgdisk -t 3:8300 ${DISK}

# make filesystems
echo -e "\nCreating Filesystems...\n$HR"

mkfs.fat -F32 "${DISK}p1"
mkfs.ext4 "${DISK}p2"
mkfx.ext4 "${DISK}p3"

# mount target
mkdir /mnt
mount "${DISK}p2" /mnt
mkdir /mnt/home
mount "${DISK}p3" /mnt/home

mkdir /mnt/etc
genfstab -U -p /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab

pacstrap -i /mnt base

arch-chroot /mnt <<"EOT"
pacman -S git
git clone https://github.com/aarondovturkel/archmatic
pacman -S sudo
chmod +x ./archmatic/0b-preinstall-chroot.sh
echo $$
EOT

arch-chroot /mnt

umount -a

echo 'Ready to reboot!'
