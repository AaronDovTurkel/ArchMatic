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

sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk ${DISK}
  o # clear the in memory partition table
  n # new partition
  p # primary partition
  1 # partition number 1
    # default - start at beginning of disk 
  +500M # 100 MB boot parttion
  t
  1
  n # new partition
  p # primary partition
  2 # partion number 2
    # default, start immediately after preceding partition
  +30G
  n
  p
  3
  
    # default, extend partition to end of disk
  w # write the partition table
  q # and we're done
EOF

lsblk

fdisk ${DISK} p

# make filesystems
echo -e "\nCreating Filesystems...\n$HR"

mkfs.fat -F32 "${DISK}p1"
mkfs.ext4 "${DISK}p2"
mkfs.ext4 "${DISK}p3"

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
pacman -S git sudo --noconfirm
git clone https://github.com/aarondovturkel/archmatic
chmod +x ./archmatic/0b-preinstall-chroot.sh
EOT

arch-chroot /mnt

umount -a

echo 'Ready to reboot!'
