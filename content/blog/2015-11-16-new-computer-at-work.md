---
title: 'New computer at work'
date: '2015-11-16'
tags:
  - 'work'
  - 'install'
  - 'arch'
  - 'linux'
---

I just got a new notebook at work. This is a HP computer, with a AMD a10-4600M
processor, 4GB of RAM and 320GB of HD space.
I have a personal notebook with a similar configuration and my work desktop also
has a similar configuration, so this isn't a great improvement.
However, we're gonna have an additional monitor, so this is good enough.
Also, I'll leave the other one as the always-on screen+irssi computer.
Let's try to use it. Talk to me again in a week.

I'll leave a list of commands I used to install Archlinux on it for future
reference. Maybe someday I'll comment it, but most things here can be found on
[the beginners' guide](https://wiki.archlinux.org/index.php/beginners'_guide).

```
ls /sys/firmware/efi/efivars
ip link set enp1s0 down
netctl start MYCONFIGURATION
mkparted /dev/sda
mklabel gpt
parted /dev/sda
(parted) mkpart primary ext4 1MiB 100MiB
(parted) set 1 boot on
(parted) mkpart primary ext4 100MiB 30GiB
(parted) mkpart primary linux-swap 30GiB 38GiB
(parted) mkpart primary ext4 38GiB 100%
(parted) quit
mkfs.ext4 /dev/sda1
mkfs.ext4 /dev/sda2
mkfs.ext4 /dev/sda4
mkswap /dev/sda3
swapon /dev/sda3
mount /dev/sda2 /mnt
mkdir -p /mnt/{boot,home}
mount /dev/sda1 /mnt/boot
mount /dev/sda4 /mnt/home
cd /etc/pacman.d
cp mirrorlist{,.bk}
#grep Brazil -A 1 mirrorlist.bk | sed '/--/d' > mirrorlist
grep c3sl -B 1 mirrorlist.bk > mirrorlist
pacstrap -i /mnt base base-devel vim screen git
genfstab -U /mnt > /mnt/etc/fstab
arch-chroot /mnt /bin/bash
vim /etc/locale.gen # Uncomment en_US.UTF-8 and others
locate-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc --utc
mkinitcpio -p linux
pacman -S syslinux gptfdisk
syslinux-install_update -i -a -m
vim /boot/syslinux/syslinux.cfg
echo myhostname > /etc/hostname
pacman -S iw wpa_supplicant dialog
passwd
exit # From the chroot
cp /etc/netctl/ufpr-static /mnt/etc/netctl/ufpr-static
umount -R /mnt
reboot
```

```
netctl start ufpr-static
pacman -S xorg-server i3-wm i3lock i3status xorg-xinit xorg-twm xterm dmenu
pacman -S xf86-input-synaptics
useradd abel -g users -G wheel -m -s /bin/bash
passwd abel
visudo
# Log as abel
startx # possibly pkill X
# Download b43-firmware and install it
# Rejoice
```
