#!/usr/bin/env bash
#-------------------------------------------------------------------------
#      _          _    __  __      _   _
#     /_\  _ _ __| |_ |  \/  |__ _| |_(_)__
#    / _ \| '_/ _| ' \| |\/| / _` |  _| / _|
#   /_/ \_\_| \__|_||_|_|  |_\__,_|\__|_\__|
#  Arch Linux Post Install Setup and Config
#-------------------------------------------------------------------------

nc=$(grep -c ^processor /proc/cpuinfo)
echo "You have " $nc" cores."
echo "-------------------------------------------------"
echo "Changing the makeflags for "$nc" cores."
sudo sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j$nc"/g' /etc/makepkg.conf
echo "Changing the compression settings for "$nc" cores."
sudo sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T $nc -z -)/g' /etc/makepkg.conf

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
passwd
useradd -m -g users -G wheel adt
passwd adt
sed -i "/%wheel ALL=(ALL) ALL/s/^#//g" /etc/sudoers
mkdir -p /boot/EFI
mount /dev/nvme0n1p1 /boot/EFI
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
mkdir /boot/grub/locale
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
grub-mkconfig -o /boot/grub/grub.cfg
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
cp /etc/fstab /etc/fstab.bak
echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
cat /etc/fstab

echo "exit chroot by running 'exit' now"
