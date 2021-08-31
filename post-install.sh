#! /bin/sh

ACTUAL_DIR="$(dirname $(readlink -f $0))"
LOG_FILE=~/.post-install.log
WM_SELECTION_FILE=~/.selected_wm
OPTION=$1
DISTRO="devuan"

# ----- usage ---------
usage()
{
  echo "Configures a default bspwm / dwm desktop from scratch after a minimal netinst system installation. Valid for devuan and void linux."	
  echo " "	
  echo "Usage:  post-install.sh [ option ]"
  echo " "	
  echo "   available values for 'option' parameter:"
  echo "     0 : install and configure all wm available"
  echo "     1 : install and configure bspwm"
  echo "     2 : install and configure basic dwm"
  echo "     3 : install and configure dk"
  echo "     4 : patch dwm"
  echo "     5 : configure hosts file to block trackers"
  echo "     6 : life is easier with browsers"
  echo "     7 : kmonad"
  echo "     8 : xbps-src packges (ungoogled-chromium by marmaduke not included by default)"
  echo "     9 : void-mklive"
  echo " "	
  echo "Check the actions done on the log file: $LOG_FILE"	
  echo " "	
  exit 2
}

# ----- default packages ---------
packages () {
	sudo apt update 
	sudo apt install -y git vim xorg xserver-xorg gcc make xdo xdotool
	sudo apt install -y libx11-dev libxft-dev libharfbuzz-dev
	sudo apt install -y libpango1.0-dev libx11-xcb-dev libxcb-xinerama0-dev 
	sudo apt install -y libxcb-util0-dev libxcb-keysyms1-dev libxcb-randr0-dev libxcb-cursor-dev
	sudo apt install -y libxcb-icccm4-dev libxcb-ewmh-dev libxcb-shape0-dev
	sudo apt install -y libxinerama-dev libreadline-dev 
	sudo apt install --no-install-recommends -y compton curl dunst libnotify-bin zip unzip xwallpaper rclone
	#sudo apt install --no-install-recommends -y pcmanfm lxappearance mpv cmus papirus-icon-theme
	echo "[$(date '+%Y-%m-%d %H:%M.%s')] default packages done" >> $LOG_FILE
}

# ----- default packages (void) --------
packages_void () {
	# https://notabug.org/reback00/void-goodies
	# https://github.com/ymir-linux/void-packages
	
	sudo echo "permit nopass keepenv $USER" >> /etc/doas.conf
	sudo echo "ignorepkg=linux-firmware-nvidia" >> /etc/xbps.d/00-ignore.conf
	sudo echo "ignorepkg=linux-firmware-amd" >> /etc/xbps.d/00-ignore.conf
	# sudo echo "ignorepkg=linux5.12" >> /etc/xbps.d/00-ignore.conf
	
	sudo xbps-install -Suy xbps
	sudo xbps-install -Suy
	sudo xbps-install -Suy xorg-minimal xinit vim git bash-completion setxkbmap opendoas
	sudo xbps-remove -y linux-firmware-amd linux-firmware-nvidia
	
	
# <<<<<<< basesystem 

	sudo xbps-install -y nnn rxvt-unicode dbus
	
	# --- libraries per compilar dmenu / dwm / wmname / st ---
	# sudo xbps-install -y gcc make  libX11-devel libXft-devel libXinerama-devel 
	# sudo xbps-install -y pkg-config

	# --- libraries to complie bspwm / sxhkd / dk ---
	# sudo xbps-install -y xcb-util-devel xcb-util-wm-devel xcb-util-cursor-devel xcb-util-keysyms-devel 
	
	sudo xbps-install -y xrandr xdo xdotool curl xwallpaper xrdb xclip jq unzip xsetroot
	#sudo xbps-install -y picom pcmanfm lxappearance archlabs-themes papirus-icon-theme mpv rclone scid_vs_pc libnotify
	sudo ln -s /etc/sv/dbus /var/service

	echo "[$(date '+%Y-%m-%d %H:%M.%s')] default packages done" >> $LOG_FILE
}

# ----- folders: HOME and /opt/git ---------
basicfolders () {
	mkdir ~/downloads ~/music ~/bin ~/bin/dwm ~/pictures ~/pictures/walls ~/videos
	sudo mkdir /opt/git
	sudo chown $USER:$USER /opt/git
	cp -r $ACTUAL_DIR /opt/git
	cd $ACTUAL_DIR
	cp bin/colors.sh bin/getcolor bin/nnnopen bin/pirokit bin/scratchpad bin/updatehosts bin/vm.sh bin/ytp bin/wallpaper* bin/encpass.sh bin/share ~/bin
	cp -r dmenu ~/bin
	chmod +x ~/bin/* ~/bin/dmenu/*
	echo "! Xresources configs --- " >> ~/.Xresources
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] home folders created" >> $LOG_FILE
}

# ----- download and install youtube-dl from github ---------
youtube_downloader () {
	sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
	sudo chmod a+rx /usr/local/bin/youtube-dl
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] youtube-dl ready" >> $LOG_FILE
}

# ----- brosers (qutebrowser & LibreWolf) ---------
browsers () {
	# https://github.com/qutebrowser/qutebrowser/blob/master/doc/help/configuring.asciidoc
	# https://github.com/Linuus/nord-qutebrowser/blob/master/nord-qutebrowser.py
	
	if [ "$DISTRO" = "devuan" ]; then
		sudo apt install -y qutebrowser
	else
		sudo xbps-install -Sy qutebrowser python3-adblock
	fi
	mkdir -p ~/.config/qutebrowser/themes
	cd $ACTUAL_DIR
	cp qutebrowser/config.py  ~/.config/qutebrowser/
	cp qutebrowser/xavi.py qutebrowser/nord.py  ~/.config/qutebrowser/themes/

    curl -L -o ~/downloads/LibreWolf-90.0.2-1.x86_64.AppImage 'https://gitlab.com/librewolf-community/browser/appimage/-/jobs/1450294189/artifacts/raw/LibreWolf-90.0.2-1.x86_64.AppImage'
   	sudo mkdir /opt/LibreWolf
	sudo chown $USER:$USER /opt/LibreWolf
	mv ~/downloads/LibreWolf-90.0.2-1.x86_64.AppImage /opt/LibreWolf/
	chmod +x /opt/LibreWolf/LibreWolf-90.0.2-1.x86_64.AppImage
	sudo ln -fs /opt/LibreWolf/LibreWolf-90.0.2-1.x86_64.AppImage /usr/local/bin/LibreWolf
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] browsers" >> $LOG_FILE
}

# ---------  kmonad  -------------
kmonad () {
	if [ "$DISTRO" = "devuan" ]; then
		curl -L -o ~/downloads/kmonad 'https://github.com/kmonad/kmonad/releases/download/0.4.1/kmonad-0.4.1-linux'
		chmod +x ~/downloads/kmonad
		sudo mv ~/downloads/kmonad /usr/local/bin	
	else
		sudo xbps-install -Sy kmonad
	fi
}

# ----- dunst  ----------------
notify_dunst () {
	if [ "$DISTRO" = "voidlinux" ]; then
		sudo xbps-install -y dunst
	fi
	[ ! -d ~/.config/dunst ] && mkdir -p ~/.config/dunst
	cp $ACTUAL_DIR/dunstrc ~/.config/dunst
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] dunst configured" >> $LOG_FILE
}

# ----- nerd fonts ---------
fonts() {
	# https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/CascadiaCode/Bold/complete/Caskaydia%20Cove%20Bold%20Nerd%20Font%20Complete.otf
	# https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/CascadiaCode/Regular/complete/Caskaydia%20Cove%20Regular%20Nerd%20Font%20Complete.otf
	# https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Iosevka/Bold-Italic/complete/Iosevka%20Bold%20Italic%20Nerd%20Font%20Complete.ttf
	# https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Iosevka/Bold/complete/Iosevka%20Bold%20Nerd%20Font%20Complete.ttf
	# https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Iosevka/Italic/complete/Iosevka%20Italic%20Nerd%20Font%20Complete.ttf
	# https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Iosevka/Regular/complete/Iosevka%20Nerd%20Font%20Complete.ttf
	# https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/FiraCode/Bold/complete/Fira%20Code%20Bold%20Nerd%20Font%20Complete.ttf
	# https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/FiraCode/Regular/complete/Fira%20Code%20Regular%20Nerd%20Font%20Complete.ttf
	# https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Hack/Bold/complete/Hack%20Bold%20Nerd%20Font%20Complete.ttf
	# https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Hack/BoldItalic/complete/Hack%20Bold%20Italic%20Nerd%20Font%20Complete.ttf
	# https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Hack/Italic/complete/Hack%20Italic%20Nerd%20Font%20Complete.ttf
	# https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete.ttf
	# https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/JetBrainsMono/Ligatures/Bold/complete/JetBrains%20Mono%20Bold%20Nerd%20Font%20Complete.ttf
	# https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/JetBrainsMono/Ligatures/BoldItalic/complete/JetBrains%20Mono%20Bold%20Italic%20Nerd%20Font%20Complete.ttf
	# https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/JetBrainsMono/Ligatures/Italic/complete/JetBrains%20Mono%20Italic%20Nerd%20Font%20Complete.ttf
	# https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/JetBrainsMono/Ligatures/Regular/complete/JetBrains%20Mono%20Regular%20Nerd%20Font%20Complete.ttf
	# https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Mononoki/Bold-Italic/complete/mononoki%20Bold%20Italic%20Nerd%20Font%20Complete.ttf
	# https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Mononoki/Bold/complete/mononoki%20Bold%20Nerd%20Font%20Complete.ttf
	# https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Mononoki/Italic/complete/mononoki%20Italic%20Nerd%20Font%20Complete.ttf
	# https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Mononoki/Regular/complete/mononoki-Regular%20Nerd%20Font%20Complete.ttf
	# https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/VictorMono/Bold-Italic/complete/Victor%20Mono%20Bold%20Italic%20Nerd%20Font%20Complete.ttf
	# https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/VictorMono/Bold/complete/Victor%20Mono%20Bold%20Nerd%20Font%20Complete.ttf
	# https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/VictorMono/Italic/complete/Victor%20Mono%20Italic%20Nerd%20Font%20Complete.ttf
	# https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/VictorMono/Regular/complete/Victor%20Mono%20Regular%20Nerd%20Font%20Complete.ttf
	
	mkdir /tmp/nerdfonts
	cd /tmp/nerdfonts
	curl -L -o ubuntu.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Ubuntu.zip
	curl -L -o hack.zip https://github.com/source-foundry/Hack/releases/download/v3.003/Hack-v3.003-ttf.zip
	curl -L -o awesome-5-15.zip https://github.com/FortAwesome/Font-Awesome/releases/download/5.15.4/fontawesome-free-5.15.4-web.zip 
	curl -L -o jetbrains.zip https://download.jetbrains.com/fonts/JetBrainsMono-1.0.0.zip?fromGitHub
	unzip "*.zip"
	rm *Windows*
	sudo mkdir -p /usr/share/fonts/truetype/newfonts
	#OLDIFS=$IFS
	#IFS=$'\n'
	#fileArray=($(find . -name '*.ttf*'))
	#tLen=${#fileArray[@]}
	#IFS=$OLDIFS
	#for (( i=0; i<${tLen}; i++ ));
	#do
	#	sudo mv "${fileArray[$i]}" /usr/share/fonts/truetype/newfonts
	#done
	find . -name '*.ttf' >tmp
	while read file
	do
		sudo cp "$file" /usr/share/fonts/truetype/newfonts
	done<tmp
	sudo fc-cache -f -v
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] fonts added" >> $LOG_FILE
}

# ----- git repos  ----------------------------
gitrepos () {
	# users dotfiles :::::
	#
	# https://git.disroot.org/lumaro/dotfiles.git
	# https://git.disroot.org/tuxliban/scripts.git
	#git clone https://gitlab.com/protesilaos/st
	#git clone https://gitlab.com/protesilaos/cpdfd
	#git clone https://gitlab.com/protesilaos/lemonbar-xft.git
	#git clone https://github.com/linuxdabbler/suckless
	#git clone https://github.com/LukeSmithxyz/st
	#git clone https://github.com/torrinfail/dwmblocks
	#git clone https://gitlab.com/dwt1/st-distrotube.git
	
	#git clone https://github.com/drscream/lemonbar-xft
	#git clone https://github.com/xabarca/dotfiles
	#git clone https://github.com/baskerville/bspwm
	#git clone https://github.com/baskerville/sxhkd	sudo mkdir /opt/git
	#git clone https://git.suckless.org/wmname
	#git clone https://git.suckless.org/dwm
	#git clone https://bitbucket.org/natemaia/dk.git
	#https://github.com/ronasimi/bar
	#git clone https://github.com/jarun/nnn
	# https://gitlab.com/souperdoupe/thom-utils/-/tree/master/wefe
	#git clone https://git.torproject.org/torsocks.git
	#git clone https://github.com/LukeSmithxyz/dwmblocks
	# git clone https://github.com/dylanaraps/paleta
	
	
	if [ -z $1 ]; then
		# st - Luke Smith's suckless st fork (patched)
		git clone --depth 1 https://github.com/LukeSmithxyz/st /opt/git/st
		cd /opt/git/st
		make
		sudo ln -fs /opt/git/st/st /usr/local/bin
		# dmenu from suckless
		git clone --depth 1  https://git.suckless.org/dmenu /opt/git/dmenu 
		cd /opt/git/dmenu 
		git apply $ACTUAL_DIR/dwm_patches/dmenu-border-20201112-1a13d04.diff
		git apply $ACTUAL_DIR/dwm_patches/dmenu-center-20200111-8cd37e1.diff
		make
		sudo ln -fs /opt/git/dmenu/dmenu /usr/local/bin
		sudo ln -fs /opt/git/dmenu/dmenu_path /usr/local/bin
		sudo ln -fs /opt/git/dmenu/dmenu_run /usr/local/bin
		sudo ln -fs /opt/git/dmenu/stest /usr/local/bin
		# wmname (to be able to start JDK swing applications)
		git clone --depth 1  https://git.suckless.org/wmname /opt/git/wmname
		cd /opt/git/wmname
		make
		sudo make install
		if [ "$DISTRO" = "devuan" ]; then
			# nnn file manager
			git clone --depth 1  https://github.com/jarun/nnn /opt/git/nnn
			cd /opt/git/nnn
			make
			sudo make install
			# drscream's lemonbar with xft support
			git clone --depth 1  https://github.com/drscream/lemonbar-xft /opt/git/lemonbar-xft
			cd /opt/git/lemonbar-xft
			make
			sudo ln -fs /opt/git/lemonbar-xft/lemonbar /usr/local/bin
			# sxhkd
			git clone --depth 1  https://github.com/baskerville/sxhkd /opt/git/sxhkd
			cd /opt/git/sxhkd
			make
			sudo make install
		fi
	fi
	if [ "$1" = "bspwm" ]; then
		if [ "$DISTRO" = "devuan" ]; then
			git clone --depth 1  https://github.com/baskerville/bspwm /opt/git/bspwm
			cd /opt/git/bspwm
			make
			sudo make install
		fi
	elif [ "$1" = "dwm" ]; then
		git clone --depth 1  https://git.suckless.org/dwm  /opt/git/dwm
		cd /opt/git/dwm
		if [ "$DISTRO" = "voidlinux" ]; then
			sed -i 's/\"st\"/\"urxvtc\"/' /opt/git/dwm/config.def.h
		fi
		sed -i 's/resizehints = 1/resizehints = 0/' /opt/git/dwm/config.def.h
		make
		git clone --depth 1  https://github.com/torrinfail/dwmblocks /opt/git/dwmblocks
		cp $ACTUAL_DIR/blocks.h /opt/git/dwmblocks
		cd /opt/git/dwmblocks
		make
		sudo ln -fs /opt/git/dwm/dwm /usr/local/bin
		sudo ln -fs /opt/git/dwmblocks/dwmblocks /usr/local/bin
	elif [ "$1" = "dk" ]; then
		git clone --depth 1  https://bitbucket.org/natemaia/dk.git /opt/git/dk
		cd /opt/git/dk
		make
		sudo ln -fs /opt/git/dk/dk /usr/local/bin
		sudo ln -fs /opt/git/dk/dkcmd /usr/local/bin
	fi
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] git repos cloned, compiled and installed ($1)" >> $LOG_FILE
}

get_herbe() {
	if [ "$DISTRO" = "voidlinux" ]; then
		sudo xbps-install -Suy gcc make libX11-devel libXft-devel libXinerama-devel 
	fi
	git clone --depth 1  https://github.com/dudik/herbe /opt/git/herbe
	cd /opt/git/herbe
	curl -o patch_Xresources.diff https://patch-diff.githubusercontent.com/raw/dudik/herbe/pull/11.diff
	git apply patch_Xresources
	make
	sudo ln -fs /opt/git/herbe/herbe /usr/local/bin
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] herbe repo cloned and installed with Xresources support" >> $LOG_FILE
}


# ----- configure default bspwm -------------------
defaultbspwm () {
	if [ "$DISTRO" = "voidlinux" ]; then
		sudo xbps-install -y sxhkd lemonbar-xft bspwm 
	fi
	mkdir ~/.config ~/.config/bspwm ~/.config/sxhkd
	cp /usr/share/doc/bspwm/examples/bspwmrc ~/.config/bspwm/
	cp /opt/git/dotfiles/bspwm/sxhkdrc ~/.config/sxhkd/
	chmod +x ~/.config/bspwm/bspwmrc
	chmod +x ~/.config/sxhkd/sxhkdrc
	if [ "$DISTRO" = "devuan" ]; then
		sed -i 's/urxvt/st/' ~/.config/sxhkd/sxhkdrc
	else
		sed -i 's/urxvt/urxvtc/' ~/.config/sxhkd/sxhkdrc
	fi
	sed -i 's/super + @space/super + p/' ~/.config/sxhkd/sxhkdrc
	echo "bspc rule -a scratch state=floating sticky=on"  >> ~/.config/bspwm/bspwmrc
	echo "xsetroot -cursor_name left_ptr &" >> ~/.config/bspwm/bspwmrc
	if [ "$DISTRO" = "devuan" ]; then
		echo "compton &" >> ~/.config/bspwm/bspwmrc
	else
		echo "picom &" >> ~/.config/bspwm/bspwmrc
	fi	
	echo "dunst &" >> ~/.config/bspwm/bspwmrc
	if [ "$DISTRO" = "voidlinux" ]; then
		echo "urxvtd -q -o -f &" >> ~/.config/bspwm/bspwmrc 
	fi
    echo " " >> ~/.config/sxhkd/sxhkdrc
	echo "super + ntilde" >> ~/.config/sxhkd/sxhkdrc
	echo "    /home/$USER/bin/scratchpad" >> ~/.config/sxhkd/sxhkdrc
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] bspwm & sxhkd installed and configured" >> $LOG_FILE
	lemonbarpanelbsp	
}

# ----- configure dwm -----------------------------
configdwm () {
	cp $ACTUAL_DIR/bin/dwm* ~/bin/dwm
	chmod +x ~/bin/dwm/*
	echo "~/bin/dwm/dwm-start" >> .xinitrc
	patchdwm
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] dwm configured" >> $LOG_FILE

# From Luke Smith dwmblocks repo (https://github.com/LukeSmithxyz/dwmblocks):
# Most statusbars constantly rerun every script every several seconds to update. This is an option here, but a superior 
# choice is giving your module a signal that you can signal to it to update on a relevant event, rather than having it rerun idly.
# For example, the audio module has the update signal 10 by default. Thus, running 
#       pkill -RTMIN+10 dwmblocks 
# will update it.
# You can also run 
#       kill -44 $(pidof dwmblocks)
# which will have the same effect, but is faster. Just add 34 to your typical signal number.
# My volume module never updates on its own, instead I have this command run along side my volume shortcuts in dwm to only update it when relevant.
# Note that if you signal an unexpected signal to dwmblocks, it will probably crash. So if you disable a module, 
# remember to also disable any cronjobs or other scripts that might signal to that module.	
}


# ----- patch dwm -----------------------------
patchdwm () {
	echo "For patching dwm, use ~/bin/dwm/dwm_git_lab.sh script."
}

# ----- configure dk -----------------------------
configdk () {
	mkdir -p ~/.config/dk
	mkdir -p ~/.config/sxhkd
	cp /opt/git/dk/doc/scripts/bar.sh ~/bin/dk-bar.sh
	cp /opt/git/dk/doc/dkrc ~/.config/dk/
	cp /opt/git/dk/doc/sxhkdrc ~/.config/sxhkd/sxhkdrc.dk
	chmod +x ~/.config/dk/dkrc
	chmod +x ~/.config/sxhkd/sxhkdrc.dk
	chmod +x ~/bin/dk-bar.sh
	sed -i 's/alt/super/' ~/.config/sxhkd/sxhkdrc.dk
	sed -i 's/sxhkd \&/sxhkd -c ~\/\.config\/sxhkd\/sxhkdrc\.dk/' ~/.config/dk/dkrc
	sed -i 's/exit 0/compton \&/' ~/.config/dk/dkrc
	echo "dunst &" >> ~/.config/dk/dkrc
	echo "~/bin/dk-bar.sh &" >> ~/.config/dk/dkrc	
	echo "exit 0" >> ~/.config/dk/dkrc
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] dk configured" >> $LOG_FILE
}

# ----- lemonbar panel -----------------------------
lemonbarpanelbsp () {
	cp $ACTUAL_DIR/bspwm/panel* ~/bin
	cp $ACTUAL_DIR/bspwm/launch-bar ~/bin
	chmod +x ~/bin/*
	echo "~/bin/bspwm/launch-bar &" >> ~/.config/bspwm/bspwmrc
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] lemonbar panel configured" >> $LOG_FILE
}

# ----- wallpaper ----------------------------------
walls () {
	cd ~/pictures/walls
	curl -O http://static.simpledesktops.com/uploads/desktops/2012/01/25/enso3.png
	curl -O http://static.simpledesktops.com/uploads/desktops/2018/07/29/night.png
	curl -O http://static.simpledesktops.com/uploads/desktops/2018/03/29/ESTRES.png
	curl -O http://static.simpledesktops.com/uploads/desktops/2016/07/19/Path.png
	curl -O http://static.simpledesktops.com/uploads/desktops/2013/02/22/Desktop_Squares.png
	curl -O http://static.simpledesktops.com/uploads/desktops/2014/10/15/tetons-at-night.png
	curl -O http://static.simpledesktops.com/uploads/desktops/2015/03/21/coffee-pixels.png
	curl -O http://static.simpledesktops.com/uploads/desktops/2015/03/02/mountains-on-mars.png
	curl -O http://static.simpledesktops.com/uploads/desktops/2015/02/20/zentree_1.png
	curl -O http://static.simpledesktops.com/uploads/desktops/2013/09/18/wallpaper.png
	[ -f ~/.config/bspwm/bspwmrc ] && echo "wallpaper-loop &" >> ~/.config/bspwm/bspwmrc
	if [ -f ~/.config/dk/dkrc ]; then
		sed -i 's/exit 0/wallpaper-loop \&/' ~/.config/dk/dkrc
		echo "exit 0" >> ~/.config/dk/dkrc
	fi
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] wallpapers downloaded and working" >> $LOG_FILE
}

# ----- xbps-src from github----------------------------
void_xbps_src() {
	# by Jose Santos (AgarimOS)  from:  https://au.ytprivate.com/watch?v=q7Q9gecxSts
	#
	# 1) instalación de xtools:
	#      sudo xbps-install -Syu xtools
	# 2) Clonar los repositorios:
	#      git clone https://github.com/void-linux/void-packages
	#      cd void-packages
	# 	   ./xbps-src binary-bootstrap
	# 3) clonar el repositorio de nvoid:
	#      git clone https://github.com/not-void/nvoid​
	# 4) mover la carpeta ungoogled-chromium-marmaduke a la copia de los repositorios de void linux (/void-packages/srcpkgs/ )
	# 5) des la carpeta "void-packages" ejecutar
	#      ./xbps-src pkg -jx ungoogled-chromium-marmaduke
	#    donde x es el número de hilos. Yo creo que incluso podíamos omitir esta opción. 
	#    En el caso de compilaciones más largas nos ahorraría bastante tiempo (compilando un kernel por ejemplo).
	# 6) instalar el paquete:
	#      xi ungoogled-chromium-marmaduke
	sudo xbps-install -Suy xtools
	git clone --depth 1  https://github.com/void-linux/void-packages /opt/git/void-packages
	
	# git clone https://github.com/not-void/nvoid /opt/git/nvoid
	# cp -r /opt/git/nvoid/srcpkgs/ungoogled-chromium-marmaduke /opt/git/void-packages/srcpkgs
	cd /opt/git/void-packages  
	./xbps-src binary-bootstrap
	# ./xbps-src pkg ungoogled-chromium-marmaduke
	# xi ungoogled-chromium-marmaduke
}

# ----- void-mklive from github ----------------------------
void_mklive() {
	sudo xbps-install -Suy xtools
	git clone --depth 1  https://github.com/void-linux/void-mklive /opt/git/void-mklive
	cd /opt/git/void-mklive
	make
}


# ----- xinit & bashrc ----------------------------
finalsetup () {
	youtube_downloader
	notify_dunst
	cd $ACTUAL_DIR
	cat Xresources >> ~/.Xresources
	echo "xrdb ~/.Xresources &" >> ~/.xinitrc
	echo "setxkbmap es &" >> ~/.xinitrc
	cat bashrc >> ~/.bashrc
	if [ "$WM_SELECTION" = "dwm" ]; then
		echo "~/bin/dwm/dwm-start" >> ~/.xinitrc
	elif [ "$WM_SELECTION" = "bspwm" ]; then
		echo "exec bspwm" >> ~/.xinitrc
	elif [ "$WM_SELECTION" = "dk" ]; then
		echo "~/bin/bar-dk.sh &" >> .xinitrc 
		echo "exec dk" >> ~/.xinitrc 
	elif [ "$WM_SELECTION" = "all" ]; then
		echo "if [ -f $WM_SELECTION_FILE ]; then" >> ~/.xinitrc
		echo "   SEL=\$(cat $WM_SELECTION_FILE)" >> ~/.xinitrc
		echo "   if [ \$SEL = dwm ]; then"  >> ~/.xinitrc
		echo "      dwm-start" >> ~/.xinitrc
		echo "   elif [ \$SEL = dk ]; then" >> ~/.xinitrc
		echo "      ~/bin/bar-dk.sh &" >> ~/.xinitrc
		echo "      exec dk" >> ~/.xinitrc
		echo "   else" >> ~/.xinitrc
		echo "      exec bspwm" >> ~/.xinitrc
		echo "   fi"  >> ~/.xinitrc
		echo "else"  >> ~/.xinitrc
		echo "   exec bspwm"  >> ~/.xinitrc
		echo "fi" >> ~/.xinitrc
	fi
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] xinitrc & bash alias setups done" >> $LOG_FILE
}

# ----- update /etc/hosts --------------------------
updatehosts() {
	cd $ACTUAL_DIR
	cp bin/updatehosts ~/bin/updatehosts
	chmod +x updatehosts
	~/bin/updatehosts
}





# ||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||

[ -z $OPTION ] && usage

# check if we are in Void Linux
case "$( uname -a )" in 
   *oid*)
      DISTRO="voidlinux"
      ;;
esac

if [ "$OPTION" = "0" ]; then
	WM_SELECTION="all"
	if [ "$DISTRO" = "devuan" ]; then
		packages && basicfolders && fonts && gitrepos \
			&& gitrepos bspwm && gitrepos dwm && gitrepos dk && defaultbspwm && configdwm && configdk \
			&& walls && finalsetup && echo "bspwm & dwm & dk configured. Please, reboot system."
	else
		packages_void && basicfolders && fonts && gitrepos \
			&& gitrepos dwm && defaultbspwm && configdwm && walls && finalsetup && echo "bspwm & dwm configured. Please, reboot system."
	fi
	echo "bspwm" > $WM_SELECTION_FILE
elif [ "$OPTION" = "1" ]; then
	WM_SELECTION="bspwm"
	if [ "$DISTRO" = "devuan" ]; then
		packages && basicfolders && fonts && gitrepos \
			&& gitrepos bspwm && defaultbspwm \
			&& walls && finalsetup && echo "bspwm configured. Please, reboot system."
	else
		packages_void && basicfolders && fonts && gitrepos \
			&& defaultbspwm && walls && finalsetup && echo "bspwm configured. Please, reboot system."
	fi
	echo "bspwm" > $WM_SELECTION_FILE
elif [ "$OPTION" = "2" ]; then
	WM_SELECTION="dwm"
	if [ "$DISTRO" = "devuan" ]; then
		packages && basicfolders && fonts && gitrepos \
			&& gitrepos dwm && configdwm \
			&& walls && finalsetup && echo "dwm configured. Please, reboot system."
	else
		packages_void && basicfolders && fonts && gitrepos \
			&& gitrepos dwm && configdwm && walls && finalsetup && echo "dwm configured. Please, reboot system."
	fi
	echo "dwm" > $WM_SELECTION_FILE
elif [ "$OPTION" = "3" ]; then
	WM_SELECTION="dk"
	if [ "$DISTRO" = "devuan" ]; then
		packages && basicfolders && fonts && gitrepos \
			&& gitrepos dk && configdk \
			&& walls && finalsetup && echo "dk configured. Please, reboot system."
	else
		packages_void && basicfolders && fonts && gitrepos \
			&& gitrepos dk && configdk && walls && finalsetup && echo "dk configured. Please, reboot system."
	fi
	echo "dk" > $WM_SELECTION_FILE
elif [ "$OPTION" = "4" ]; then
	patchdwm
elif [ "$OPTION" = "5" ]; then
	updatehosts
elif [ "$OPTION" = "6" ]; then
	browsers
elif [ "$OPTION" = "7" ]; then
	kmonad
elif [ "$OPTION" = "8" ]; then
	void_xbps_src
elif [ "$OPTION" = "9" ]; then
	void_mklive
else
	usage
fi
