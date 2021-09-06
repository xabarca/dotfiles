#!/bin/bash

UEFI=0 # 1=UEFI, 0=Legacy/BIOS platform along the script
# SWAP=1 # 1=ON, 0=OFF
SEPARATED_HOME_PARTITION=1  # 1=yes || 0=no

# SETTINGS
REPO='https://alpha.de.repo.voidlinux.org'
ARCH='x86_64' # glibc or musl
USERNAME='xavi' # Set your username
HOSTNAME='voidmusl' # Pick your favorite name
HARDWARECLOCK='UTC' # Set RTC (Real Time Clock) to UTC or localtime
TIMEZONE='Europe/Andorra' # Set which region on Earth the user is
KEYMAP='es' # Define keyboard layout: us or br-abnt2 (include more options)
FONT='Lat2-Terminus16' # Set type face for terminal before X server starts
TTYS=2 # Amount of ttys which should be setup. VARIABLE NOT USED !
# LANG='en_US.UTF-8' # I guess this one only necessary in glibc install

# packages to install
PKG_LIST='base-system git vim bash-completion setxkbmap grub' # Install this packages (add more to your taste)

# PARTITIONS SIZE (M for Megabytes, G for Gigabytes)
EFISIZE='512M' # 512MB for /boot/efi should be sufficient to host 7 to 8 kernel versions
SWAPSIZE='1G'
ROOTSIZE='5G'

# - - - - - - - - - - - - - - - - - - - - - - - -
_device_selection() {
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
		echo "\n\nInvalid input..."
        sleep 2
        _device_selection
	  fi
	done
	
	# Verify if is a NVMe device, then add 'p' in variable for partitions
	[ $(echo $opt | grep '^nvme') ] && DEV_PART_NAME+='p'
}

# - - - - - - - - - - - - - - - - - - - - - - - -
_get_packages_to_install() {
# base-system="
#      base-files>=0.77 ncurses coreutils findutils diffutils libgcc
#      dash bash grep gzip file sed gawk less util-linux which tar man-pages
#      mdocml>=1.13.3 shadow e2fsprogs btrfs-progs xfsprogs f2fs-tools dosfstools
#      procps-ng tzdata pciutils usbutils iana-etc openssh dhcpcd
#      kbd iproute2 iputils iw wpa_supplicant xbps nvi sudo wifi-firmware
#      void-artwork traceroute ethtool kmod acpid eudev runit-void removed-packages"

# base-minimal="
#    base-files coreutils findutils diffutils dash grep gzip sed gawk
#    util-linux which tar shadow procps-ng iana-etc xbps nvi tzdata
#    runit-void removed-packages"

# 	PKG_LIST="base-minimal linux5.12 linux5.12-headers dracut"
# 	PKG_LIST="$PKG_LIST less man-pages e2fsprogs procps-ng pciutils usbutils iproute2 util-linux kbd wifi-firmware ethtool kmod traceroute iputils"
# 	PKG_LIST="$PKG_LIST base-files>=0.77 bash dosfstools openssh opendoas sudo wifi-firmware acpid eudev"
# 	PKG_LIST="$PKG_LIST vim dhcpcd wpa_supplicant bash-completion setxkbmap git grub"
	
	PKG_LIST="base-system"
	PKG_LIST="$PKG_LIST vim opendoas bash-completion setxkbmap git grub"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
_filetype_selection() {
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
		echo "\n\nInvalid input..."
		sleep 2
		_filetype_selection
	  fi
	done
}

# - - - - - - - - - - - - - - - - - - - - - - - -
_wipe_disk() {
	clear
	echo ''
	echo 'WIPE DISK'
	wipe="dd if=/dev/zero of=${DEV_DISK_NAME} bs=1M count=100"
	echo ''
	read -p "Wipe Disk Before installation (for security reasons) ? [Y/n]: " answ
	[ "$answ" = "n" ] && wipe=""
	# Wipe /dev/${DEVNAME} (Wiping a disk is done by writing new data over every single bit - font: https://wiki.archlinux.org/index.php/Securely_wipe_disk)
	$wipe
}

# - - - - - - - - - - - - - - - - - - - - - - - -
_musl () { 
    clear
	echo ''
	echo 'GLIBC OR MUSL ARCHITECTURE'
    echo ""
    echo "  1 - glibc"
    echo "  2 - musl"
    echo ""
    read -p "Please enter your choice (1 or 2): " choice
    case $choice in
       1 ) ARCH="x86_64" ;;
       2 ) ARCH="x86_64-musl" ;;
       * ) echo "\nOption not correct...." ; sleep 1; _musl ;;
    esac
}

# - - - - - - - - - - - - - - - - - - - - - - - -
_disk_partition_and_mnt() {
	
	# SEPARATED_HOME_PARTITION
	
    # Device Partioning for UEFI/GPT or BIOS/MBR
    #  - sfdisk help :::  U:uefi | S:swap | L:linux | *:bootable 
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

# - - - - - - - - - - - - - - - - - - - - - - - -
_fstab() {
	# SEPARATED_HOME_PARTITION
	
	echo "# For reference: <file system> <dir> <type> <options> <dump> <pass>" >> /mnt/etc/fstab
	echo "tmpfs /tmp  tmpfs defaults,nosuid,nodev 0 0" >> /mnt/etc/fstab
	echo "$(blkid ${DEV_PART_NAME}1 | cut -d ' ' -f 4 | tr -d '"') /boot vfat  rw,fmask=0133,dmask=0022,noatime,discard  0 2" >> /mnt/etc/fstab
	echo "$(blkid ${DEV_PART_NAME}2 | cut -d ' ' -f 3 | tr -d '"') swap  swap  commit=60,barrier=0  0 0" >> /mnt/etc/fstab
	echo "$(blkid ${DEV_PART_NAME}3 | cut -d ' ' -f 3 | tr -d '"') / $FSYS rw,noatime,discard,commit=60,barrier=0 0 1" >> /mnt/etc/fstab
	echo "$(blkid ${DEV_PART_NAME}4 | cut -d ' ' -f 3 | tr -d '"') /home $FSYS rw,discard,commit=60,barrier=0 0 2 " >> /mnt/etc/fstab
	
		
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
}

# - - - - - - - - - - - - - - - - - - - - - - - -
_username() { 
	clear
	echo ''
	echo 'USERNAME '
	echo ''
	echo -e "\n"
	read -p "Type username : " USERNAME
	echo ''
	[[ -z "$USERNAME" ]] && _username
}

# - - - - - - - - - - - - - - - - - - - - - - - -
_hostname () { 
	clear
	echo ''
	echo 'HOSTNAME '
	echo ''
	echo -e "\n"
	read -p "Type hostname (void will be used if empty) : " HOSTNAME
	echo ''
	[[ -z "$HOSTNAME" ]] && HOSTNAME="void"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
_userpwd () { 
	clear
	echo ''
	echo 'PASSWORD FOR USER $USERNAME '
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

# - - - - - - - - - - - - - - - - - - - - - - - -
_rootpwd () { 
	clear
	echo ''
	echo 'PASSWORD FOR ROOT '
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

# - - - - - - - - - - - - - - - - - - - - - - - -
_sshd() {
	clear
	echo ''
	echo 'SSH DAEMON INSTALLATION '
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
sleep 1

# Exit immediately if a command exits with a non-zero exit status
# set -e

# Set installation font (more legible)
setfont $FONT

_device_selection
_filetype_selection
_musl
_hostname
_username
_userpwd
_rootpwd
_sshd

# Detect if we're in UEFI or legacy mode installation
[ -d /sys/firmware/efi ] && UEFI=1

_wipe_disk
_disk_partition_and_mnt
_get_packages_to_install

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
if [ "$ARCH" = "x86_64" ]; then
    env XBPS_ARCH=x86_64 xbps-install -Sy -R ${REPO}/current -r /mnt $PKG_LIST
else
    env XBPS_ARCH=x86_64-musl xbps-install -Sy -R ${REPO}/current/musl -r /mnt $PKG_LIST
fi

# Upon completion of the install, we set up our chroot jail, and chroot into our mounted filesystem:
# for i in sys dev proc; do $(mount --rbind /$i /mnt/$i && mount --make-rslave /mnt/$i); done
mount -t proc proc /mnt/proc
mount -t sysfs sys /mnt/sys
mount -o bind /dev /mnt/dev
mount -t devpts pts /mnt/dev/pts

######################
### CHROOTed START ###
######################
# clear
# echo ''
# echo 'Set Root Password'
# echo ''
# # create the password for the root user
# while true; do
#    chroot /mnt passwd root && break
#    echo ''
# done

chroot /mnt -c "(echo '$ROOTPWD' ; echo '$ROOTPWD') | passwd root"
chroot /mnt -c "useradd -g users -G wheel,storage,audio,kvm,xbuilder,input $USERNAME"
chroot /mnt -c "(echo '$USERPWD' ; echo '$USERPWD') | passwd $USERNAME"
	

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

if [ "$ARCH" = "x86_64" ]; then
	# modify /etc/default/libc-locales and uncomment:
	#en_US.UTF-8 UTF-8
	sed -i 's/#ca_ES.UTF/ca_ES.UTF/' /mnt/etc/default/libc-locales
	sed -i 's/#en_US.UTF/en_US.UTF/' /mnt/etc/default/libc-locales
	chroot /mnt  xbps-reconfigure -f glibc-locales

	# OLD CONFIGS
	# echo "LANG=$LANG" > /mnt/etc/locale.conf
	# echo "$LANG $(echo ${LANG} | cut -f 2 -d .)" >> /mnt/etc/default/libc-locales
	# chroot /mnt xbps-reconfigure -f glibc-locales
	# OLD CONFIGS
fi


# FSTAB - START ==========

_fstab

#  clear
#  echo ''
#  echo 'Generating /etc/fstab'
#  echo ''
#  
#  if [ $UEFI -eq 1 ]; then
#    cat > /mnt/etc/fstab <<EOF
#  # For reference: <file system> <dir> <type> <options> <dump> <pass>
#  tmpfs /tmp  tmpfs defaults,nosuid,nodev 0 0
#  $(blkid ${DEV_PART_NAME}1 | cut -d ' ' -f 4 | tr -d '"') /boot vfat  rw,fmask=0133,dmask=0022,noatime,discard  0 2
#  $(blkid ${DEV_PART_NAME}2 | cut -d ' ' -f 3 | tr -d '"') swap  swap  commit=60,barrier=0  0 0
#  $(blkid ${DEV_PART_NAME}3 | cut -d ' ' -f 3 | tr -d '"') / $FSYS rw,noatime,discard,commit=60,barrier=0 0 1
#  $(blkid ${DEV_PART_NAME}4 | cut -d ' ' -f 3 | tr -d '"') /home $FSYS rw,discard,commit=60,barrier=0 0 2
#  EOF
#  else
#    cat > /mnt/etc/fstab <<EOF
#  # For reference: <file system> <dir> <type> <options> <dump> <pass>
#  tmpfs /tmp  tmpfs defaults,nosuid,nodev 0 0
#  $(blkid ${DEV_PART_NAME}1 | cut -d ' ' -f 3 | tr -d '"') swap  swap  commit=60,barrier=0  0 0
#  $(blkid ${DEV_PART_NAME}2 | cut -d ' ' -f 3 | tr -d '"') / $FSYS rw,noatime,discard,commit=60,barrier=0 0 1
#  $(blkid ${DEV_PART_NAME}3 | cut -d ' ' -f 3 | tr -d '"') /home $FSYS rw,discard,commit=60,barrier=0 0 2
#  EOF
#  fi

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
# useradd -g users -G wheel,storage,audio,kvm,xbuilder,input $USERNAME
# Set password
echo 'Define password for user ${USERNAME}'
echo ''
#while true; do
#  passwd $USERNAME && break
#  echo ''
#done

# Add sudo permissions
echo '%wheel ALL=(ALL) ALL, NOPASSWD: /usr/bin/halt, /usr/bin/poweroff, /usr/bin/reboot, /usr/bin/zzz, /usr/bin/ZZZ, /usr/bin/mount, /usr/bin/umount' > /etc/sudoers.d/99_wheel
# Update mirrors
# echo 'repository=${REPO}/current/musl' > /etc/xbps.d/00-repository-main.conf
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
sleep 5

poweroff
