#!/bin/sh

[ -x "$(command -v sudo)" ] && ld="sudo" 
[ -x "$(command -v doas)" ] && [ -e /etc/doas.conf ] && ld="doas"

# ----- default packages ---------
packages () {
	$ld apt update 
	$ld apt install --no-install-recommends -y git neovim doas
	$ld apt install --no-install-recommends -y xorg xserver-xorg xdo xdotool xautolock socat xsel xclip age
	$ld apt install --no-install-recommends -y libtk8.6
	$ld apt install --no-install-recommends -y pcmanfm lxappearance imagemagick mpv sxhkd aria2
	$ld apt install --no-install-recommends -y xcompmgr curl zip unzip xwallpaper rclone iw iwd rxvt-unicode wget
	#$ld apt install --no-install-recommends -y cmus papirus-icon-theme 
	$ld apt install -y elogind
}


packages
