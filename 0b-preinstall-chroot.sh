#!/usr/bin/env bash
#-------------------------------------------------------------------------
#      _          _    __  __      _   _
#     /_\  _ _ __| |_ |  \/  |__ _| |_(_)__
#    / _ \| '_/ _| ' \| |\/| / _` |  _| / _|
#   /_/ \_\_| \__|_||_|_|  |_\__,_|\__|_\__|
#  Arch Linux Post Install Setup and Config
#-----------------------------------------------------------------------

echo EFI_DISK
read -sp "Please enter root password:" rootpassword
read -sp "Please repeat root password:" rootpassword2

# Check both passwords match
if [ "$rootpassword" != "$rootpassword2" ]; then
    echo "Passwords do not match, try running the script again"
    exit 1
fi

read -p "Please enter username:" username
read -sp "Please enter password:" password
read -sp "Please repeat password:" password2

# Check both passwords match
if [ "$password" != "$password2" ]; then
    echo "Passwords do not match, try running the script again"
    exit 1
fi

pacman -S linux linux-headers linux-lts linux-lts-headers linux-firmware --noconfirm --needed
echo -e "\nInstalling Base System\n"
PKGS=(
  'nano'
  'vim'
  'base-devel'
  'openssh'
  'networkmanager'
  'wpa_supplicant'
  'wireless_tools'
  'netctl'
  'dialog'
  'sudo'
  'grub'
  'efibootmgr'
  'dosfstools'
  'os-prober'
  'mtools'
  'intel-ucode'
  'xorg-server'
  'mesa'
  'xf86-video-intel'
)
for PKG in "${PKGS[@]}"; do
    echo "INSTALLING: ${PKG}"
    pacman -S "$PKG" --noconfirm --needed
done
echo -e "\nDone!\n"

systemctl enable sshd
systemctl enable NetworkManager

mkinitcpio -p linux
mkinitcpio -p linux-lts

sed -i "/en_US.UTF-8/s/^#//g" /etc/locale.gen
locale-gen

# Setting root password
echo $rootpassword | passwd –-stdin

# creating user and setting password
useradd -m -g users -G wheel $username
echo $password | passwd –-stdin $username

sed -i "/%wheel ALL=(ALL) ALL/s/^#//g" /etc/sudoers

# Setting boot partition
mkdir -p /boot/EFI
mount ${EFI_DISK} /boot/EFI
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck

mkdir /boot/grub/locale
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
grub-mkconfig -o /boot/grub/grub.cfg

# Creating swapfile
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile

cp /etc/fstab /etc/fstab.bak
echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
cat /etc/fstab

echo "exit chroot by running 'exit' now"
