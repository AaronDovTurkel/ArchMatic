#!/usr/bin/env bash
#-------------------------------------------------------------------------
#      _          _    __  __      _   _
#     /_\  _ _ __| |_ |  \/  |__ _| |_(_)__
#    / _ \| '_/ _| ' \| |\/| / _` |  _| / _|
#   /_/ \_\_| \__|_||_|_|  |_\__,_|\__|_\__|
#  Arch Linux Post Install Setup and Config
#-------------------------------------------------------------------------

echo -e "\nINSTALLING AUR SOFTWARE\n"

cd /opt

echo "CLONING: YAY"
git clone "https://aur.archlinux.org/yay.git"
sudo chown adt:users ./yay

PKGS=(

    # UTILITIES -----------------------------------------------------------

    'i3lock-fancy'              # Screen locker
    
    # MEDIA ---------------------------------------------------------------

    'screenkey'                 # Screencast your keypresses
    'lbry-app-bin'              # LBRY Linux Application
    

    # THEMES --------------------------------------------------------------

    'lightdm-webkit-theme-aether'   # Lightdm Login Theme - https://github.com/NoiSek/Aether#installation
    'materia-gtk-theme'             # Desktop Theme
    'papirus-icon-theme'            # Desktop Icons
    'capitaine-cursors'             # Cursor Themes
)


cd yay
makepkg -si

for PKG in "${PKGS[@]}"; do
    yay -S --noconfirm $PKG
done

echo -e "\nDone!\n"
