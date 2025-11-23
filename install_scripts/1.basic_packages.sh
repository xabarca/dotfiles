#!/bin/sh

[ -x "$(command -v sudo)" ] && ld="sudo" 
[ -x "$(command -v doas)" ] && [ -e /etc/doas.conf ] && ld="doas"

# ----- default packages ---------
_packages () {
	$ld apt update 
	$ld apt install --no-install-recommends -y git neovim doas
	$ld apt install --no-install-recommends -y xorg xserver-xorg xdo xdotool socat xsel xclip age xterm
	#$ld apt install --no-install-recommends -y xautolock
	$ld apt install --no-install-recommends -y libtk8.6
	$ld apt install --no-install-recommends -y pcmanfm lxappearance imagemagick mpv sxhkd aria2 nnn fuse yad
	$ld apt install --no-install-recommends -y xcompmgr curl zip unzip xwallpaper rclone iw iwd rxvt-unicode wget
	$ld apt install --no-install-recommends -y arc-theme papirus-icon-theme
 	#$ld apt install --no-install-recommends -y cmus
	#$ld apt install -y elogind
}

# ----- compiling packages ---------
_packages_compile () {
	$ld apt update 
	$ld apt install --no-install-recommends -y gcc make
	$ld apt install --no-install-recommends -y libx11-dev libxft-dev libharfbuzz-dev
	$ld apt install --no-install-recommends -y libpango1.0-dev libx11-xcb-dev libxcb-xinerama0-dev 
	$ld apt install --no-install-recommends -y libxinerama-dev libreadline-dev 
	$ld apt install --no-install-recommends -y libxrandr-dev libimlib2-dev libxpm-dev
	# next ones needed fot compile spectrwm
	$ld apt install --no-install-recommends -y libxcursor-dev
	# next two/three lines are needed only for compile bspwm
	# $ld apt install --no-install-recommends -y libxcb-util0-dev libxcb-keysyms1-dev libxcb-randr0-dev libxcb-cursor-dev
	# $ld apt install --no-install-recommends -y libxcb-icccm4-dev libxcb-ewmh-dev libxcb-shape0-dev
	# $ld apt install --no-install-recommends -y libxcb-res0-dev
}


_packages
_packages_compile
