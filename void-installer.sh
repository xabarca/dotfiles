#! /bin/sh

#### Visone-Void-Installer

## This script will allow you to install a void-linux system by the chroot and xbps-install method. You could choose between glibc or musl system.
## This script does NOT make partitions.
## This script works only with UEFI systems for now

BOOT=/dev/vda1
ROOT=/dev/vda2
# MODE=1::glibc  MODE=2::musl
MODE=2
USERNAME=xavi
USERPASSWORD=admin1234
ROOTPASSWORD=voidlinux
HOSTNAME=void



install() {

	# Creating filesystems and mounting them

	mkfs.fat -F32 /dev/$BOOT
	mkfs.ext4 /dev/$ROOT
	mount /dev/$ROOT /mnt
	mkdir -p /mnt/boot/efi
	mount /dev/$BOOT /mnt/boot/efi

	# Choosing C library glibc or musl

	### Musl pkgs

	# Base-system & Base-devel

	PkgsBase="base-files>=0.77 ncurses-devel coreutils findutils diffutils libgcc musl mksh grep gzip file sed gawk less util-linux which tar mdocml>=1.13.3 shadow dosfstools procps-ng tzdata pciutils usbutils iana-etc openssh kbd iproute2 iputils  wpa_supplicant xbps sudo  traceroute ethtool kmod acpid eudev runit-void removed-packages ca-certificates dracut linux5.13 linux5.13-headers linux-firmware-amd linux-firmware-network acpid musl make gcc pkg-config patch"

	PkgsXorg="xorg-minimal xf86-video-amdgpu mesa-dri mesa-vaapi mesa-vdpau"

	PkgsService="connman samba tlp"

	PkgsAudio="pulseaudio alsa-plugins-pulseaudio"

	PkgsDwm="libX11-devel libXft-devel libXinerama-devel freetype-devel fontconfig-devel harfbuzz-devel"

	PkgsApps="mpv ranger neovim xclip ffmpeg rofi kitty transmission-gtk pywal feh git  font-Siji zsh zsh-syntax-highlighting zsh-autosuggestions"

	GlibPkgs="void-repo-nonfree qutebrowser python3-adblock telegram-desktop linux-firmware-nvidia"

	# Settings easily pkgs variables

	MP="$PkgsBase $PkgsXorg $PkgsService $PkgsAudio $PkgsDwm $PkgsApps"
	GP="$PkgsBase $PkgsXorg $PkgsService $PkgsAudio $PkgsDwm $PkgsApps $GlibPkgs"

	case $mode in

		1)REPO=https://alpha.de.repo.voidlinux.org/current 
		ARCH=x86_64
		PKGS="$GP" 
		2)REPO=https://alpha.de.repo.voidlinux.org/current/musl
		ARCH=x86_64-musl
		PKGS="$MP" 
		
	esac

	## Installing base-system

	XBPS_ARCH=$ARCH xbps-install -S -r /mnt -R "$REPO"  "$PKGS"
	XBPS_ARCH=$ARCH xbps-install -S -r /mnt -R "$REPO"
	XBPS_ARCH=$ARCH xbps-install -S -r /mnt -R "$REPO" chromium-widevine

	## Mounting pseudofilesystems

	for i in sys dev proc; do $(mount --rbind /$i /mnt/$i && mount --make-rslave /mnt/$i); done

	## Configurations various

	cp configs/resolve.conf /mnt/etc/
	cp configs/hosts /mnt/etc/
	cp configs/60-ioshedulers.rules /mnt/run/udev/rules.d/
	echo "$hostname" /mnt/etc/hostname
	chroot /mnt -c "ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime "
	cp configs/rc.conf /mnt/etc
	cp configs/Reynholm-Industries-psk.config /mnt/etc/wpa_supplicant/
	cp configs/settings /mnt/var/lib/connman/
	cp configs/tlp.conf /mnt/etc/tlp.conf
	cp -r configs/xorg.d /mnt/X11/
	cp -r configs/xbps.d /mnt/etc/
	cp -r configs/cron.weekly  /mnt/etc/
	cp -r configs/agetty-autologin-tty1 /mnt/etc/sv/
	chroot /mnt -c "mkdir /media/Datos.Local && cd /media && chown -R $user:users Datos.Local "
	chroot /mnt -c " cd /var/service/ && rm -rf agetty-tty6 agetty-tty5 agetty-tty4 agetty-tty3 agetty-tty1 dhcp* "
	chroot /mnt -c " ln -s /etc/sv/agetty-autologin-tty1 /var/service"
	chroot /mnt -c " ln -s /etc/sv/connmand /var/service"

	# Users and Passwds and visudo config

	chroot /mnt -c "(echo $rootpasswd ; echo $rootpasswd) | passwd root"
	chroot /mnt -c "useradd -m -G users,video,audio,network,storage,xbilder,input $user"
	chroot /mnt -c "(echo $userpasswd ; echo $userpasswd) | passwd $user"
	sed -i "80i $user ALL=(ALL) ALL"  /mnt/etc/sudoers
	sed -i "81i $user ALL=(ALL) NOPASSWD: /usr/bin/halt, /usr/bin/poweroff, /usr/bin/reboot, /usr/bin/shutdown " /mnt/etc/sudoers

	## Config fstab
	touch /mnt/etc/fstab
	echo "$(blkid /dev/$boot | awk '{print $2}' | sed 's/"//g') /boot/efi vfat defaults,noatime 0 2 " /mnt/etc/fstab
	echo "$(blkid /dev/$root | awk '{print $2}' | sed 's/"//g') / ext4 defaults,noatime 0 1 " /mnt/etc/fstab
	echo "tmpfs           /tmp        tmpfs   defaults,nosuid,nodev   0 0" /mnt/etc/fstab
	echo "UUID=368e731d-9cc2-4286-b84d-784f89556747 /media/Datos.Local ext4 errors=remount-ro 0 0" /mnt/etc/fstab

	## Installing grub

	chroot /mnt -c "grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=visone-void"

	# Reconfiguring pkgs

	chroot /mnt -c "xbps-reconfigure -fa"

	## Setting dotfiles

	cp -r /media/Datos.Local/linux/repo.git/laptop-void-musl/* /mnt/home/visone/
	chroot /mnt -c "cd /home/visone/ && chown -R visone:users *"
}


menu() {
	echo " Instalation Menu "
	echo ""
	echo "Boot Partition /dev/XXX"
	read boot
	echo "Root Partition /dev/XXX"
	read root
	echo " Choose a glib or musl system    1.- glibc  2.- musl"
	read mode
	echo " User Name"
	read user
	echo "Root Passwd"
	read -s rootpasswd
	echo "User Passwd"
	read -s userpasswd
	echo " Hostname"
	read $hostname
}

menu
install
