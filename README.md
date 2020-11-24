# ADT's ArchMatic Installer Script

This README contains the steps I do to install and configure a fully-functional Arch Linux installation containing a desktop environment, all the support packages (network, bluetooth, audio, printers, etc.), along with all my preferred applications and utilities. The shell scripts in this repo allow the entire process to be automated.)

---

## Setup Boot and Arch ISO on USB key

First, setup the boot USB, boot arch live iso, and connect to wifi with `iwct`. 

### Arch Live ISO (Pre-Install)

This step installs arch to your hard drive. *IT WILL FORMAT THE DISK*
After connecting to the internet run `pacman -Syyy`.
If no erros occur you are connected to the internet and you can continue.

```bash
git clone https://github.com/aarondovturkel/archmatic
./archmatic/0a-preinstall-base.sh
reboot
```

### Arch Linux First Boot

Connect to the internet with `nmcli`.

```bash
pacman -S --no-confirm pacman-contrib curl git
mkdir scripts
cd scripts
git clone https://github.com/aarondovturkel/archmatic
cd archmatic
./1-base.sh
./2-software-pacman.sh
./3-software-aur.sh
./4-post-setup.sh
```

### Don't just run these scripts. Examine them. Customize them. Create your own versions.

---

### System Description
This runs BSPWM with default config.

This boots with `grub`and partitions the disk in three: 500M for kernel, 30G for root, and rest for home.

I also install the LTS Kernel along side the rolling one, and configure my bootloader to offer both as a choice during startup. This enables me to switch kernels in the event of a problem with the rolling one.

### Troubleshooting Arch Linux

__[Arch Linux Installation Gude](https://github.com/rickellis/Arch-Linux-Install-Guide)__

#### No Wifi

```bash
iwctl`
station *device* connect *SSID*
```

#### Initialize Xorg:
At the terminal, run:

```bash
xinit
```
