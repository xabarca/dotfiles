#!/bin/sh


# ----- default packages ---------
packages () {
	sudo apt update 
	sudo apt install --no-install-recommends -y git neovim doas
	sudo apt install --no-install-recommends -y xorg xserver-xorg xdo xdotool xautolock socat xsel xclip age
	sudo apt install --no-install-recommends -y libtk8.6
	sudo apt install --no-install-recommends -y pcmanfm lxappearance imagemagick mpv sxhkd
	sudo apt install --no-install-recommends -y xcompmgr curl zip unzip xwallpaper rclone iw rxvt-unicode
	#sudo apt install --no-install-recommends -y cmus papirus-icon-theme 
	sudo apt install -y elogind
}


packages
