#! /bin/sh

ACTUAL_DIR="$(dirname $(readlink -f $0))"
LOG_FILE=/tmp/post-install.log
WM_SELECTION_FILE=~/.selected_wm
OPTION=$1

# ----- usage ---------
usage()
{
  echo "Configures a bspwm/dwm default desktop from scratch on a devuan/debian base system."	
  echo " "	
  echo "Usage:  post-install.sh [ option ]"
  echo " "	
  echo "   available values for 'option' parameter:"
  echo "     0 : install and configure both bspwm & dwm"
  echo "     1 : install and configure bspwm"
  echo "     2 : install and configure dwm"
  echo " "	
  echo "Check the actions done on the log file: $LOG_FILE"	
  echo " "	
  exit 2
}

# ----- default packages ---------
packages () {
	sudo apt update
	sudo apt install -y git vim xorg xserver-xorg gcc make xdo
	sudo apt install -y libx11-dev lifxft-dev libxinerama-dev 
	sudo apt install -y libpango1.0-dev libx11-xcb-dev libxcb-xinerama0-dev 
	sudo apt install -y libxcb-util0-dev libxcb-keysyms1-dev libxcb-randr0-dev
	sudo apt install -y libxcb-icccm4-dev libxcb-ewmh-dev libxcb-shape0-dev
	sudo apt install -y compton feh fonts-font-awesome curl vifm dunst libnotify-bin
	#sudo apt install -y pcmanfm lxappearance mpv cmus
	echo "[$(date '+%Y-%m-%d %H:%M.%s')] default packages done" >> $LOG_FILE
}

# ----- folders in HOME ---------
homefolders () {
	mkdir ~/downloads ~/music ~/bin ~/pictures ~/pictures/walls ~/videos
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] home folders created" >> $LOG_FILE
}

# ----- git repos  ----------------------------
gitrepos () {
	#git clone https://gitlab.com/protesilaos/st
	#git clone https://gitlab.com/protesilaos/cpdfd
	#git clone https://gitlab.com/protesilaos/lemonbar-xft.git
	#git clone https://github.com/linuxdabbler/suckless
	#git clone https://github.com/drscream/lemonbar-xft
	#git clone https://github.com/xabarca/dotfiles
	#git clone https://github.com/LukeSmithxyz/st
	#git clone https://github.com/baskerville/bspwm
	#git clone https://github.com/baskerville/sxhkd	sudo mkdir /opt/git
	#git clone https://git.suckless.org/dwm
	sudo chown $USER /opt/git
	cd /opt/git
	git clone https://github.com/LukeSmithxyz/st
	git clone https://gitlab.com/protesilaos/lemonbar-xft.git
	git clone https://github.com/baskerville/bspwm
	git clone https://github.com/baskerville/sxhkd
	git clone https://github.com/linuxdabbler/suckless /opt/git/suckless_linuxdabbler
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] git repos cloned" >> $LOG_FILE
}

# ----- git compiling + install -------------------
gitinstalls () {
	cd /opt/git/lemonbar-xft
	make
	cd /opt/git/st
	make
	cd /opt/git/suckless_linuxdabbler/dmenu
	make
	cd /opt/git/bspwm
	make
	sudo make install
	cd /opt/git/sxhkd
	make
	sudo make install
	sudo ln -fs /opt/git/lemonbar-xft/lemonbar ~/usr/local/bin
	sudo ln -fs /opt/git/st/st ~/usr/local/bin
	sudo ln -fs /opt/git/suckless_linuxdabbler/dmenu/dmenu ~/usr/local/bin
	sudo ln -fs /opt/git/suckless_linuxdabbler/dmenu/dmenu_path ~/usr/local/bin
	sudo ln -fs /opt/git/suckless_linuxdabbler/dmenu/dmenu_run ~/usr/local/bin
	sudo ln -fs /opt/git/suckless_linuxdabbler/dmenu/stest ~/usr/local/bin
	chmod +x /opt/git/suckless_linuxdabbler/dmenu/dmenu
	chmod +x /opt/git/suckless_linuxdabbler/dmenu/dmenu_path
	chmod +x /opt/git/suckless_linuxdabbler/dmenu/dmenu_run
	chmod +x /opt/git/suckless_linuxdabbler/dmenu/stest
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] compiled and installed git packages" >> $LOG_FILE
}

# ----- configure default bspwm -------------------
defaultbspwm () {
	mkdir ~/.config ~/.config/bspwm ~/.config/sxhkd
	cp /opt/git/bspwm/examples/bspwmrc ~/.config/bspwm/
	cp /opt/git/bspwm/examples/sxhkdrc ~/.config/sxhkd/
	chmod +x ~/.config/bspwm/bspwmrc
	chmod +x ~/.config/sxhkd/sxhkdrc
	sed -i 's/urxvt/st/' ~/.config/sxhkd/sxhkdrc
	sed -i 's/super + @space/super + p/' ~/.config/sxhkd/sxhkdrc
	#echo "feh --bg-scale ~/pictures/walls/night.png &" >> ~/.config/bspwm/bspwmrc
	echo "xsetroot -cursor_name left_ptr &" >> ~/.config/bspwm/bspwmrc
	echo "compton &" >> ~/.config/bspwm/bspwmrc
	echo "dunst &" >> ~/.config/bspwm/bspwmrc
	echo "bspwm" >> $WM_SELECTION_FILE
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] bspwm & sxhkd installed and configured" >> $LOG_FILE
}

# ----- lemonbar panel && wallpaper ---------------
lemonbarpanel () {
	cp $ACTUAL_DIR/panel* ~/bin
	cp $ACTUAL_DIR/launch-bar ~/bin
	chmod +x ~/bin/*
	echo "launch-bar &" >> ~/.config/bspwm/bspwmrc
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] lemonbar panel configured" >> $LOG_FILE
}

# ----- lemonbar panel && wallpaper ---------------
walls () {
	cp $ACTUAL_DIR/wallpaper* ~/bin
	chmod +x ~/bin/wallpaper*
	cd ~/pictures/walls
	curl -O http://static.simpledesktops.com/uploads/desktops/2012/01/25/enso3.png
	curl -O http://static.simpledesktops.com/uploads/desktops/2018/07/29/night.png
	curl -O http://static.simpledesktops.com/uploads/desktops/2014/09/02/pulsarmap.png
	curl -O http://static.simpledesktops.com/uploads/desktops/2014/10/15/tetons-at-night.png
	curl -O http://static.simpledesktops.com/uploads/desktops/2015/03/21/coffee-pixels.png
	curl -O http://static.simpledesktops.com/uploads/desktops/2015/03/02/mountains-on-mars.png
	curl -O http://static.simpledesktops.com/uploads/desktops/2015/02/20/zentree_1.png
	curl -O http://static.simpledesktops.com/uploads/desktops/2013/09/18/wallpaper.png
	echo "wallpaper-loop &" >> ~/.config/bspwm/bspwmrc
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] wallpapers downloaded" >> $LOG_FILE
}

# ----- xinit & bash ------------------------------
finalsetup () {
	sed -i 's/#alias ll=/alias ll=/' ~/.bashrc
	echo "exec bspwm" >> ~/.xinitrc
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] xinitrc & bash alias setups done" >> $LOG_FILE
}


-- ||||||||||||||||||||||||||||||||||||||||
-- ||||||||||||||||||||||||||||||||||||||||
-- ||||||||||||||||||||||||||||||||||||||||
-- ||||||||||||||||||||||||||||||||||||||||
-- ||||||||||||||||||||||||||||||||||||||||

[ -z $OPTION ] && usage

if [ "$OPTION" = "0" ]; then
	WM_SELECTION="all"
	packages && homefolders && gitrepos && gitinstalls && defaultbspwm && lemonbarpanel && walls && finalsetup && echo "bspwm & dwm configured. Please, reboot system."
elif [ "$OPTION" = "1" ]; then
	WM_SELECTION="bspwm"
	packages && homefolders && gitrepos && gitinstalls && defaultbspwm && lemonbarpanel && walls && finalsetup && echo "bspwm configured. Please, reboot system."
elif [ "$OPTION" = "2" ]; then
	WM_SELECTION="dwm"
	#packages && homefolders && gitrepos && gitinstalls && defaultbspwm && lemonbarpanel && walls && finalsetup && echo "dwm configured. Please, reboot system."
	echo "Option no implemented yet"
else
	usage
fi
