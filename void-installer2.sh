#!/bin/bash

# Name: Void Linux Installer
# Authors: Marcílio Nascimento <marcilio.mcn at gmail.com>
# First Release: 2019, March
# Description: Alternative LEAN install script that replaces the standard Void Linux installer.
# License: MIT
# Version: 202003.01

# Exit immediately if a command exits with a non-zero exit status
set -e

# Declaring LV array (for LVM)
# declare -A LV

##############################
######## HEADER START ########
##############################
# DECLARE CONSTANTS AND VARIABLES
UEFI=0 # 1=UEFI, 0=Legacy/BIOS platform along the script
# SWAP=1 # 1=ON, 0=OFF

# REPO="http://alpha.us.repo.voidlinux.org"
REPO='https://alpha.de.repo.voidlinux.org'

# VGNAME="vgpool"
# CRYPTSETUP_OPTS=""
# UPDATETYPE='-Sy' # If GenuineIntel update local repository and change the next one to only '-y'

# PARTITIONS SIZE (M for Megabytes, G for Gigabytes)
EFISIZE='512M' # 512MB for /boot/efi should be sufficient to host 7 to 8 kernel versions
SWAPSIZE='1G'
ROOTSIZE='5G'

# LVM Size ARRAY (testing)
# LV[root]="2G"
# LV[var]="2G" - Test if necessary for desktop
# LV[home]="1G"

# SETTINGS
USERNAME='xavi' # Set your username
HOSTNAME='voidmusl' # Pick your favorite name
HARDWARECLOCK='UTC' # Set RTC (Real Time Clock) to UTC or localtime
TIMEZONE='Europe/Andorra' # Set which region on Earth the user is
KEYMAP='es' # Define keyboard layout: us or br-abnt2 (include more options)
FONT='Lat2-Terminus16' # Set type face for terminal before X server starts
TTYS=2 # Amount of ttys which should be setup
# LANG='en_US.UTF-8' # I guess this one only necessary in glibc installs
PKG_LIST='base-system git vim grub dhcpcd bash-completion setxkbmap' # Install this packages (add more to your taste)
############################
######## HEADER END ########
############################

# Set installation font (more legible)
setfont $FONT

clear
echo '######################################'
echo '######## Void Linux Installer ########'
echo '######################################'

# Option to select the device type/name
echo ''
echo 'DEVICE SELECTION'
echo ''
PS3='Select your device (type the number option): '
options=$(lsblk | awk '/disk/ { print $1 }')
select opt in $options; do
  if [ ! -z $opt ]; then
    DEV_DISK_NAME="/dev/${opt}"
    DEV_PART_NAME="/dev/${opt}"
    break
  else  
    printf 'This option is invalid.\n\n'
  fi
done

# Verify if is a NVMe device, then add 'p' in variable for partitions
[ $(echo $opt | grep '^nvme') ] && DEV_PART_NAME+='p'

# Option to select the file system type to format paritions
clear
echo ''
echo 'FILE SYSTEM TYPE SELECTION'
echo ''
PS3='Select the file system type to format partitions (type the number option): '
filesystems='ext2 ext3 ext4 xfs'
select filesysformat in $filesystems; do
  if [ ! -z $filesysformat ]; then
    FSYS=$filesysformat
    break
  else  
    printf 'This option is invalid.\n\n'
  fi
done

clear
echo ''
echo '######## WIPE DISK ########'
wipe="dd if=/dev/zero of=${DEV_DISK_NAME} bs=1M count=100"
echo ''
read -p "Wipe Disk ? [Y/n]:" answ
[ "$answ" = "n" ] && wipe=""
# Wipe /dev/${DEVNAME} (Wiping a disk is done by writing new data over every single bit - font: https://wiki.archlinux.org/index.php/Securely_wipe_disk)
$wipe

# Detect if we're in UEFI or legacy mode installation
[ -d /sys/firmware/efi ] && UEFI=1

###### DISK PREPARATION - START ######
# Device Partioning for UEFI/GPT or BIOS/MBR
if [ $UEFI -eq 1 ]; then
  # PARTITIONING
  sfdisk $DEV_DISK_NAME <<EOF
    label: gpt
    ,${EFISIZE},U,*
    ,${SWAPSIZE},S
    ,${ROOTSIZE},L
    ,,L
EOF
  # FORMATING
  # In UEFI, format EFI partition as FAT32
  mkfs.vfat -F 32 -n EFI ${DEV_PART_NAME}1
  mkswap -L swp0 ${DEV_PART_NAME}2
  mkfs.$FSYS -L voidlinux ${DEV_PART_NAME}3
  mkfs.$FSYS -L home ${DEV_PART_NAME}4

  # MOUNTING
  mount ${DEV_PART_NAME}3 /mnt
  mkdir /mnt/boot && mount ${DEV_PART_NAME}1 /mnt/boot
  mkdir /mnt/home && mount ${DEV_PART_NAME}4 /mnt/home

  # When UEFI
  mkdir /mnt/boot/efi && mount ${DEV_PART_NAME}1 /mnt/boot/efi
else
  sfdisk $DEV_DISK_NAME <<EOF
    label: dos
    ,${SWAPSIZE},S
    ,${ROOTSIZE},L,*
    ,,L
EOF
  # FORMATING
  mkswap -L swp0 ${DEV_PART_NAME}1
  mkfs.$FSYS -L voidlinux ${DEV_PART_NAME}2
  mkfs.$FSYS -L home ${DEV_PART_NAME}3

  # MOUNTING
  mount ${DEV_PART_NAME}2 /mnt
  mkdir /mnt/home && mount ${DEV_PART_NAME}3 /mnt/home
fi
###### DISK PREPARATION - END ######

# Allow automatic import repository keys
mkdir -p /mnt/var/db/xbps/keys/
cp -a /var/db/xbps/keys/* /mnt/var/db/xbps/keys/

###### LVM AND CRYPTOGRAPHY - START ######

# # Options for encrypt partitions process
# if [ $UEFI ]; then
#   BOOTPART="3"
#   ROOTPART="4"
# else
#   BOOTPART="2"
#   ROOTPART="3"
# fi

# # Start PKG_LIST variable and increase packages by the process installation
# PKG_LIST="lvm2 cryptsetup"

# # Install requirements for LVM and Cryptography
# xbps-install -Syf $PKG_LIST

# echo "Encrypt - boot partition"
# cryptsetup ${CRYPTSETUP_OPTS} luksFormat -c aes-xts-plain64 -s 512 /dev/${DEVNAME}${BOOTPART}

# echo "Open - boot partition"
# cryptsetup luksOpen /dev/${DEVNAME}${BOOTPART} crypt-boot

# echo "Encrypt - root partition"
# cryptsetup ${CRYPTSETUP_OPTS} luksFormat -c aes-xts-plain64 -s 512 /dev/${DEVNAME}${ROOTPART}

# echo "Open - root partition"
# cryptsetup luksOpen /dev/${DEVNAME}${ROOTPART} crypt-pool

# # Create VolumeGroup
# pvcreate /dev/mapper/crypt-pool
# vgcreate ${VGNAME} /dev/mapper/crypt-pool
# for FS in ${!LV[@]}; do
#   lvcreate -L ${LV[$FS]} -n ${FS/\//_} ${VGNAME}
# done

# # If exist SWAP, create LV drive
# [ $SWAP -eq 1 ] && lvcreate -L ${SWAPSIZE} -n swap ${VGNAME}
# #if [ $SWAP -eq 1 ]; then
# #  lvcreate -L ${SWAPSIZE} -n swap ${VGNAME}
# #fi

# mkfs.ext4 -L boot /dev/mapper/crypt-boot

# for FS in ${!LV[@]}; do
#   mkfs.ext4 -L ${FS/\//_} /dev/mapper/${VGNAME}-${FS/\//_}
# done

# if [ $SWAP -eq 1 ]; then
#   mkswap -L swap /dev/mapper/${VGNAME}-swap
# fi

# # Mount them
# mount /dev/mapper/${VGNAME}-root /mnt

# for dir in dev proc sys boot; do
#   mkdir /mnt/${dir}
# done

# ## Remove root and sort keys
# unset LV[root]

# for FS in $(for key in "${!LV[@]}"; do printf '%s\n' "$key"; done| sort); do
#   mkdir -p /mnt/${FS}
#   mount /dev/mapper/${VGNAME}-${FS/\//_} /mnt/${FS}
# done

# if [ $UEFI ]; then
#   mount /dev/mapper/crypt-boot /mnt/boot
#   mkdir /mnt/boot/efi
#   mount /dev/${DEVNAME}1 /mnt/boot/efi
# else
#   mount /dev/mapper/crypt-boot /mnt/boot
# fi

# for fs in dev proc sys; do
#   mount -o bind /${fs} /mnt/${fs}
# done

###### LVM AND CRYPTOGRAPHY - END ######

###### PREPARING VOID LINUX INSTALLING PACKAGES ######
# If UEFI installation, add GRUB specific package
[ $UEFI -eq 1 ] && PKG_LIST+='-x86_64-efi'

# Install Void Linux
clear
echo ''
echo 'Installing Void Linux files'
echo ''
env XBPS_ARCH=x86_64-musl xbps-install -Sy -R ${REPO}/current/musl -r /mnt $PKG_LIST

# Upon completion of the install, we set up our chroot jail, and chroot into our mounted filesystem:
mount -t proc proc /mnt/proc
mount -t sysfs sys /mnt/sys
mount -o bind /dev /mnt/dev
mount -t devpts pts /mnt/dev/pts

######################
### CHROOTed START ###
######################
clear
echo ''
echo 'Set Root Password'
echo ''
# create the password for the root user
while true; do
  chroot /mnt passwd root && break
  echo ''
done

clear
echo ''
echo 'Adjust/Correct Root Permissions'
chroot /mnt chown root:root /
chroot /mnt chmod 755 /

clear
echo ''
echo 'Customizations'
echo $HOSTNAME > /mnt/etc/hostname

cat >> /mnt/etc/rc.conf <<EOF
HARDWARECLOCK="${HARDWARECLOCK}"
TIMEZONE="${TIMEZONE}"
KEYMAP="${KEYMAP}"
FONT="${FONT}"
TTYS=2
EOF

##################################################
#### GLIBC ONLY - START - USE GLIBC IMAGE ISO ####
##################################################

# modify /etc/default/libc-locales and uncomment:
#en_US.UTF-8 UTF-8

# Or whatever locale you want to use. And run:
#xbps-reconfigure -f glibc-locales

# OLD CONFIGS
# echo "LANG=$LANG" > /mnt/etc/locale.conf
# echo "$LANG $(echo ${LANG} | cut -f 2 -d .)" >> /mnt/etc/default/libc-locales
# chroot /mnt xbps-reconfigure -f glibc-locales
# OLD CONFIGS

##########################
#### GLIBC ONLY - END ####
##########################

# FSTAB - START ==========
clear
echo ''
echo 'Generating /etc/fstab'
echo ''

if [ $UEFI -eq 1 ]; then
  cat > /mnt/etc/fstab <<EOF
# For reference: <file system> <dir> <type> <options> <dump> <pass>
tmpfs /tmp  tmpfs defaults,nosuid,nodev 0 0
$(blkid ${DEV_PART_NAME}1 | cut -d ' ' -f 4 | tr -d '"') /boot vfat  rw,fmask=0133,dmask=0022,noatime,discard  0 2
$(blkid ${DEV_PART_NAME}2 | cut -d ' ' -f 3 | tr -d '"') swap  swap  commit=60,barrier=0  0 0
$(blkid ${DEV_PART_NAME}3 | cut -d ' ' -f 3 | tr -d '"') / $FSYS rw,noatime,discard,commit=60,barrier=0 0 1
$(blkid ${DEV_PART_NAME}4 | cut -d ' ' -f 3 | tr -d '"') /home $FSYS rw,discard,commit=60,barrier=0 0 2
EOF
else
  cat > /mnt/etc/fstab <<EOF
# For reference: <file system> <dir> <type> <options> <dump> <pass>
tmpfs /tmp  tmpfs defaults,nosuid,nodev 0 0
$(blkid ${DEV_PART_NAME}1 | cut -d ' ' -f 3 | tr -d '"') swap  swap  commit=60,barrier=0  0 0
$(blkid ${DEV_PART_NAME}2 | cut -d ' ' -f 3 | tr -d '"') / $FSYS rw,noatime,discard,commit=60,barrier=0 0 1
$(blkid ${DEV_PART_NAME}3 | cut -d ' ' -f 3 | tr -d '"') /home $FSYS rw,discard,commit=60,barrier=0 0 2
EOF
fi

# for FS in $(for key in "${!LV[@]}"; do printf '%s\n' "$key"; done| sort); do
#   echo "LABEL=${FS/\//_}  /${FS}	ext4    rw,relatime,data=ordered,discard    0 0" >> /mnt/etc/fstab
# done

# Write on FSTAB if SWAP partition exist
# [ $SWAP -eq 1 ] && echo "LABEL=swap  none       swap     defaults    0 0" >> /mnt/etc/fstab
#if [ $SWAP -eq 1 ]; then
#  echo "LABEL=swap  none       swap     defaults    0 0" >> /mnt/etc/fstab
#fi
# FSTAB - END ==========

# Install GRUB
# cat << EOF >> /mnt/etc/default/grub
# GRUB_TERMINAL_INPUT="console"
# GRUB_TERMINAL_OUTPUT="console"
# GRUB_ENABLE_CRYPTODISK=y
# EOF
# sed -i 's/GRUB_BACKGROUND.*/#&/' /mnt/etc/default/grub
# chroot /mnt grub-install /dev/${DEVNAME}

# LUKS_BOOT_UUID="$(lsblk -o NAME,UUID | grep ${DEVNAME}${BOOTPART} | awk '{print $2}')"
# LUKS_DATA_UUID="$(lsblk -o NAME,UUID | grep ${DEVNAME}${ROOTPART} | awk '{print $2}')"
# echo "GRUB_CMDLINE_LINUX=\"rd.vconsole.keymap=${KEYMAP} rd.lvm=1 rd.luks=1 rd.luks.allow-discards rd.luks.uuid=${LUKS_BOOT_UUID} rd.luks.uuid=${LUKS_DATA_UUID}\"" >> /mnt/etc/default/grub

clear
echo ''
echo 'Install GRUB'
echo ''
# Install GRUB to the disk
chroot /mnt grub-install $DEV_DISK_NAME

# clear
# echo "Configurar GRUB"
# # Generate the configuration file
# chroot /mnt grub-mkconfig -o /mnt/boot/grub/grub.cfg

clear
echo ''
echo 'Read the newest kernel'
# Cat the last Linux Kernel Version
KERNEL_VER=$(chroot /mnt xbps-query -s 'linux[0-9]*' | cut -f 2 -d ' ' | cut -f 1 -d -)

clear
echo ''
echo 'Reconfigure initramfs'
echo ''
# Setup the kernel hooks (ignore grup complaints about sdc or similar)
chroot /mnt xbps-reconfigure -f $KERNEL_VER

clear
echo ''
echo '######## SSH ########'
SSH_SERVER="ln -s /etc/sv/sshd /etc/runit/runsvdir/default/"
echo ''
read -p "Enable SSH ? [Y/n]:" answ
[ "$answ" = "n" ] && SSH_SERVER=""







#  ######################
#  ### CHROOTed START ###
#  ######################
#  clear
#  echo ''
#  echo 'Set Root Password'
#  echo ''
#  # create the password for the root user
#  while true; do
#    chroot /mnt passwd root && break
#    echo ''
#  done






### SETUP SYSTEM INFOS START ###
clear
echo ''
echo '######## Setup System Infos ########'
echo ''
cat > /mnt/tmp/bootstrap.sh <<EOCHROOT
# Activate DHCP daemon to enable network connection
ln -s /etc/sv/dhcpcd /etc/runit/runsvdir/default/
# Activate SSH daemon to enable SSH server
$SSH_SERVER
# Remove all gettys except for tty1 and tty2
rm /etc/runit/runsvdir/default/agetty-tty[3456]
# Create user
useradd -g users -G wheel,storage,video,kvm,xbuilder,audio,network,input $USERNAME
# Set password
echo 'Define password for user ${USERNAME}'
echo ''
while true; do
  passwd $USERNAME && break
  echo ''
done
# Add sudo permissions
echo '%wheel ALL=(ALL) ALL, NOPASSWD: /usr/bin/halt, /usr/bin/poweroff, /usr/bin/reboot, /usr/bin/zzz, /usr/bin/ZZZ, /usr/bin/mount, /usr/bin/umount' > /etc/sudoers.d/99_wheel
# Update mirrors (best for Brazil)
echo 'repository=${REPO}/current/musl' > /etc/xbps.d/00-repository-main.conf
# echo 'repository=${REPO}/current/musl/nonfree' > /etc/xbps.d/10-repository-nonfree.conf
# Permanent swappiness optimization (great for Linux Desktops)
mkdir /etc/sysctl.d/
echo 'vm.swappiness=10' > /etc/sysctl.d/99-swappiness.conf
# Correct the grub install
update-grub
EOCHROOT

chroot /mnt /bin/sh /tmp/bootstrap.sh
### SETUP SYSTEM INFOS END ###

# VVV confirm if necessary for glibc
# grub-mkconfig > /boot/grub/grub.cfg
# grub-install $DEV

# Bugfix for EFI installations (after finished, poweroff e poweron, the system do not start)
[ $UEFI -eq 1 ] && install -D /mnt/boot/efi/EFI/void/grubx64.efi /mnt/boot/efi/EFI/BOOT/bootx64.efi

# Umount folder used for installation
umount -R /mnt

clear
echo ''
echo '####################################################'
echo '######## Void Linux Installed Successfully! ########'
echo '####################################################'
sleep 3

poweroff
