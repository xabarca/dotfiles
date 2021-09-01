#!/bin/bash

########################################
##   DECLARE CONSTANTS AND VARIABLES  ##
########################################

UEFI=0 # 1=UEFI, 0=Legacy/BIOS platform along the script
# SWAP=1 # 1=ON, 0=OFF

# SETTINGS
REPO='https://alpha.de.repo.voidlinux.org'
USERNAME='xavi' # Set your username
HOSTNAME='voidmusl' # Pick your favorite name
HARDWARECLOCK='UTC' # Set RTC (Real Time Clock) to UTC or localtime
TIMEZONE='Europe/Andorra' # Set which region on Earth the user is
KEYMAP='es' # Define keyboard layout: us or br-abnt2 (include more options)
FONT='Lat2-Terminus16' # Set type face for terminal before X server starts
TTYS=2 # Amount of ttys which should be setup
# LANG='en_US.UTF-8' # I guess this one only necessary in glibc installs
PKG_LIST='base-system git vim dhcpcd bash-completion setxkbmap grub' # Install this packages (add more to your taste)

# PARTITIONS SIZE (M for Megabytes, G for Gigabytes)
EFISIZE='512M' # 512MB for /boot/efi should be sufficient to host 7 to 8 kernel versions
SWAPSIZE='1G'
ROOTSIZE='5G'


########################################
##            FUNCTIONS               ##
########################################

_device_selection() {
	# Option to select the device type/name
	# clear
	echo ''
	echo ' DEVICE SELECTION'
	echo ''
	PS3='Select your device (type the number option): '
	options=$(lsblk | awk '/disk/ { print $1 }')
	select opt in $options; do
	  if [ ! -z $opt ]; then
		DEV_DISK_NAME="/dev/${opt}"
		DEV_PART_NAME="/dev/${opt}"
		break
	  else  
		echo "\n\nInvalid input..."
        sleep 2
        _device_selection
	  fi
	done
	
	# Verify if is a NVMe device, then add 'p' in variable for partitions
	[ $(echo $opt | grep '^nvme') ] && DEV_PART_NAME+='p'
}

_filetype_selection() {
	# Option to select the file system type to format paritions
	clear
	echo ''
	echo ' FILE SYSTEM TYPE SELECTION'
	echo ''
	PS3='Select the file system type to format partitions (type the number option): '
	filesystems='ext2 ext3 ext4 xfs'
	select filesysformat in $filesystems; do
	  if [ ! -z $filesysformat ]; then
		FSYS=$filesysformat
		break
	  else  
		echo "\n\nInvalid input..."
		sleep 2
		_filetype_selection
	  fi
	done
}

_wipe_disk() {
	clear
	echo ''
	echo ' WIPE DISK'
	wipe="dd if=/dev/zero of=${DEV_DISK_NAME} bs=1M count=100"
	echo ''
	read -p "Wipe Disk Before installation (for security reasons) ? [Y/n]: " answ
	[ "$answ" = "n" ] && wipe=""
	# Wipe /dev/${DEVNAME} (Wiping a disk is done by writing new data over every single bit - font: https://wiki.archlinux.org/index.php/Securely_wipe_disk)
	$wipe
}

_disk_partition_and_mnt() {
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
}

_userpwd () { 
	clear
	echo ''
	echo ' PASSWORD FOR USER $USERNAME '
	echo ''
	echo -e "\n"
	read -s -p "Type user password : " USERPWD
	echo ''
	read -s -p "Retype it : " USERPWD_retype
	[[ -z "$USERPWD" ]] && _userpwd
	if [[ "$USERPWD" != "$USERPWD_retype" ]]; then
		unset $USERPWD
		printf "\n\nPassword and retype doesn't match. Try again..."
		sleep 2
		_userpwd
	fi
}

_rootpwd () { 
	clear
	echo ''
	echo ' PASSWORD FOR ROOT '
	echo ''
	echo -e "\n"
	read -s -p "Type root password : " ROOTPWD
	echo ''
	read -s -p "Retype it : " ROOTPWD_retype
	[[ -z "$ROOTPWD" ]] && _userpwd
	if [[ "$ROOTPWD" != "$ROOTPWD_retype" ]]; then
		unset $ROOTPWD
		printf "\n\nPassword and retype doesn't match. Try again..."
		sleep 2
		_rootpwd
	fi
}

_sshd() {
	clear
	echo ''
	echo ' SSH DAEMON INSTALLATION '
	echo ''
	SSH_SERVER="ln -s /etc/sv/sshd /etc/runit/runsvdir/default/"
	echo ''
	read -p "Enable SSH ? [Y/n]: " answ
	[ "$answ" = "n" ] && SSH_SERVER=""
}




clear
echo '######################################'
echo '######## Void Linux Installer ########'
echo '######################################'
sleep 2

# Exit immediately if a command exits with a non-zero exit status
set -e

# Set installation font (more legible)
setfont $FONT

_device_selection
_filetype_selection
_userpwd
_rootpwd
_sshd

# Detect if we're in UEFI or legacy mode installation
[ -d /sys/firmware/efi ] && UEFI=1

_wipe_disk
_disk_partition_and_mnt

# Allow automatic import repository keys
mkdir -p /mnt/var/db/xbps/keys/
cp -a /var/db/xbps/keys/* /mnt/var/db/xbps/keys/


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

# SET ROOT PASSWORD
chroot /mnt -c "(echo $ROOTPWD ; echo $ROOTPWD) | passwd root"

# Adjust/Correct Root Permissions
chroot /mnt chown root:root /
chroot /mnt chmod 755 /

# Customizationsp
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
(echo $USERPWD ; echo $USERPWD) | passwd $USERNAME
# Add sudo permissions
echo '%wheel ALL=(ALL) ALL, NOPASSWD: /usr/bin/halt, /usr/bin/poweroff, /usr/bin/reboot, /usr/bin/zzz, /usr/bin/ZZZ, /usr/bin/mount, /usr/bin/umount' > /etc/sudoers.d/99_wheel
# Update mirrors
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
sleep 2

poweroff
