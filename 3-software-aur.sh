#!/usr/bin/env bash
#-------------------------------------------------------------------------
#      _          _    __  __      _   _
#     /_\  _ _ __| |_ |  \/  |__ _| |_(_)__
#    / _ \| '_/ _| ' \| |\/| / _` |  _| / _|
#   /_/ \_\_| \__|_||_|_|  |_\__,_|\__|_\__|
#  Arch Linux Post Install Setup and Config
#-------------------------------------------------------------------------

echo -e "\nINSTALLING AUR SOFTWARE\n"

sudo cd /opt

echo "CLONING: YAY"
sudo git clone "https://aur.archlinux.org/yay.git"
sudo chown adt:users ./yay
cd yay
makepkg -si --noconfirm --needed

PKGS=(

    # UTILITIES -----------------------------------------------------------

    'i3lock'                    # Screen locker
    'i3lock-fancy'              # Screen locker
    
    # MEDIA ---------------------------------------------------------------

    'screenkey'                 # Screencast your keypresses
    'browsh-bin'                # Terminal based browser
    

    # THEMES --------------------------------------------------------------

    'lightdm-webkit-theme-aether'   # Lightdm Login Theme - https://github.com/NoiSek/Aether#installation
    'materia-gtk-theme'             # Desktop Theme
    'papirus-icon-theme'            # Desktop Icons
    'capitaine-cursors'             # Cursor Themes
    'nerd-fonts-complete'
    'polybar'
)

for PKG in "${PKGS[@]}"; do
    yay -S $PKG --noconfirm --needed
done

echo -e "\nDone!\n"
