#!/usr/bin/env bash
#-------------------------------------------------------------------------
#      _          _    __  __      _   _
#     /_\  _ _ __| |_ |  \/  |__ _| |_(_)__
#    / _ \| '_/ _| ' \| |\/| / _` |  _| / _|
#   /_/ \_\_| \__|_||_|_|  |_\__,_|\__|_\__|
#  Arch Linux Post Install Setup and Config
#-------------------------------------------------------------------------

echo -e "\nFINAL SETUP AND CONFIGURATION"

# ------------------------------------------------------------------------

echo -e "\nGenaerating .Xresources file"

# Generate the .Xresources and set display
cat <<EOF > ${HOME}/.Xresources
#!/bin/bash

# Change this depending on your monitor
# Xft.dpi: 192 # uncomment if you have a 13" screen

! These might also be useful depending on your monitor and personal preference:
Xft.autohint: 0
Xft.lcdfilter:  lcddefault
Xft.hintstyle:  hintfull
Xft.hinting: 1
Xft.antialias: 1
Xft.rgba: rgb
EOF

# ------------------------------------------------------------------------

echo -e "\nGenaerating .xinitrc file"

# Generate the .xinitrc file so we can launch Awesome from the
# terminal using the "startx" command
cat <<EOF > ${HOME}/.xinitrc
#!/bin/bash
# Disable bell
xset -b

# Disable all Power Saving Stuff
xset -dpms
xset s off

# X Root window color
xsetroot -solid darkgrey

# Merge resources (optional)
xrdb -merge $HOME/.Xresources

sxhkd & 
exec bspwm
EOF

# ------------------------------------------------------------------------

echo -e "\nConfiguring LTS Kernel as a secondary boot option"

sed '/GRUB_DEFAULT=/s/0/saved/' /etc/default/grub
sed -i "/GRUB_SAVEDEFAULT=/s/^#//g" /etc/default/grub

sudo update-grub
# ------------------------------------------------------------------------

echo -e "\nConfiguring vconsole.conf to set a larger font for login shell"

sudo cat <<EOF > /etc/vconsole.conf
KEYMAP=us
FONT=ter-v32b
EOF

# ------------------------------------------------------------------------

echo -e "\nEnabling Login Display Manager"

sudo systemctl enable lightdm.service
sudo sed -i "/greeter-session=/s/^#//g" /etc/lightdm/lightdm.conf
sudo sed '/greeter-session=/s/example-gtk-gnome/lightdm-webkit2-greeter/' /etc/lightdm/lightdm.conf

# ------------------------------------------------------------------------

echo -e "\nSetting up default folders"

mkdir ~/images
mkdir ~/images/wallpapers
mkdir ~/images/screenshots
mkdir ~/community-dots

# ------------------------------------------------------------------------

echo -e "\nBootstrapping my dots"

cd
git clone https://github.com/aarondovturkel/dots
ln -sf ~/dots/.bashrc ~
ln -sf ~/dots/.bash_profile ~


# ------------------------------------------------------------------------

echo -e "\nSetting up BSPWM with defualt config"

mkdir ~/.config
mkdir ~/.config/bspwm
mkdir ~/.config/sxhkd

sudo cp /usr/share/doc/bspwm/examples/bspwmrc ~/.config/bspwm/bspwmrc
sudo cp /usr/share/doc/bspwm/examples/sxhkdrc ~/.config/sxhkd/sxhkdrc

sudo sed -i 's/urxvt/kitty/g' ~/.config/bspwm/bspwmrc
sudo sed -i 's/dmenu_run/rofi -show run/g' ~/.config/bspwm/bspwmrc

# ------------------------------------------------------------------------

echo -e "\nEnabling bluetooth daemon and setting it to auto-start"

sudo sed -i 's|#AutoEnable=false|AutoEnable=true|g' /etc/bluetooth/main.conf
sudo systemctl enable --now bluetooth.service

# ------------------------------------------------------------------------

echo -e "\nEnabling the cups service daemon so we can print"

sudo systemctl enable org.cups.cupsd.service
sudo ntpd -qg
sudo systemctl enable ntpd.service
sudo systemctl disable dhcpcd.service
sudo systemctl enable NetworkManager.service
echo "###############################################################################"


# Clean orphans pkg
if [[ ! -n $(pacman -Qdt) ]]; then
	echo "No orphans to remove."
else
	pacman -Rns $(pacman -Qdtq)
fi

# Replace in the same state
cd $pwd

