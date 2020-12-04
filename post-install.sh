#! /bin/sh

ACTUAL_DIR="$(dirname $(readlink -f $0))"
LOG_FILE=~/.post-install.log
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
  echo "     0 : install and configure all wm available"
  echo "     1 : install and configure bspwm"
  echo "     2 : install and configure dwm"
  echo "     3 : install and configure dk"
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
	sudo apt install -y libxcb-util0-dev libxcb-keysyms1-dev libxcb-randr0-dev libxcb-cursor-dev
	sudo apt install -y libxcb-icccm4-dev libxcb-ewmh-dev libxcb-shape0-dev
	sudo apt install -y compton feh fonts-font-awesome curl vifm dunst libnotify-bin
	#sudo apt install -y pcmanfm lxappearance mpv cmus
	echo "[$(date '+%Y-%m-%d %H:%M.%s')] default packages done" >> $LOG_FILE
}

# ----- default packages (void) --------
packages_void () {
	sudo xbps-install -Sy xbps
	sudo xbps-install -Su
	sudo xbps-install -Sy gcc make pkg-config libX11-devel libXft-devel libXinerama-devel
	sudo xbps-install -Sy xcb-util-devel xcb-util-wm-devel xcb-util-cursor-devel  xcb-util-keysyms-devel 
	
	
	sudo xbps-install -Sy git vim xorg xserver-xorg gcc make xdo
	sudo xbps-install -Sy libx11-dev lifxft-dev libxinerama-dev 
	sudo xbps-install -Sy libpango1.0-dev libx11-xcb-dev libxcb-xinerama0-dev 
	sudo xbps-install -Sy libxcb-util0-dev libxcb-keysyms1-dev libxcb-randr0-dev libxcb-cursor-dev
	sudo xbps-install -Sy libxcb-icccm4-dev libxcb-ewmh-dev libxcb-shape0-dev
	sudo xbps-install -Sy compton feh fonts-font-awesome curl vifm dunst libnotify-bin
	#sudo apt install -y spacefm lxappearance mpv cmus
	echo "[$(date '+%Y-%m-%d %H:%M.%s')] default packages done" >> $LOG_FILE
}

# ----- folders in HOME ---------
basicfolders () {
	mkdir ~/downloads ~/music ~/bin ~/pictures ~/pictures/walls ~/videos
	sudo mkdir /opt/git
	sudo chown $USER /opt/git
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
	#git clone https://bitbucket.org/natemaia/dk.git
	#git clone https://gitlab.com/dwt1/st-distrotube.git
	#https://github.com/ronasimi/bar
	if [ -z $1 ]; then
		# st - Luke Smith's suckless fork (patched)
		git clone https://github.com/LukeSmithxyz/st /opt/git/st
		cd /opt/git/st
		make
		sudo ln -fs /opt/git/st/st /usr/local/bin
		# pack of LinuxDabbler suckless utils (we want dmenu)
		git clone https://github.com/linuxdabbler/suckless /opt/git/suckless_linuxdabbler
		cd /opt/git/suckless_linuxdabbler/dmenu
		make
		sudo ln -fs /opt/git/suckless_linuxdabbler/dmenu/dmenu /usr/local/bin
		sudo ln -fs /opt/git/suckless_linuxdabbler/dmenu/dmenu_path /usr/local/bin
		sudo ln -fs /opt/git/suckless_linuxdabbler/dmenu/dmenu_run /usr/local/bin
		sudo ln -fs /opt/git/suckless_linuxdabbler/dmenu/stest /usr/local/bin
		# Protesilaos' compile of lemonbar with xft support
		#git clone https://gitlab.com/protesilaos/lemonbar-xft.git /opt/git/lemonbar-xft
		git clone https://github.com/drscream/lemonbar-xft /opt/git/lemonbar-xft
		cd /opt/git/lemonbar-xft
		make
		sudo ln -fs /opt/git/lemonbar-xft/lemonbar /usr/local/bin
		# sxhkd
		git clone https://github.com/baskerville/sxhkd /opt/git/sxhkd
		cd /opt/git/sxhkd
		make
		sudo make install
	fi
	if [ "$1" = "bspwm" ]; then
		git clone https://github.com/baskerville/bspwm /opt/git/bspwm
		cd /opt/git/bspwm
		make
		sudo make install
	elif [ "$1" = "dwm" ]; then
		git clone https://git.suckless.org/dwm  /opt/git/dwm
		cd /opt/git/dwm
		make
		sudo ln -fs /opt/git/dwm/dwm /usr/local/bin
	elif [ "$1" = "dk" ]; then
		git clone https://bitbucket.org/natemaia/dk.git /opt/git/dk
		cd /opt/git/dk
		make
		sudo ln -fs /opt/git/dk/dk /usr/local/bin
	fi
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] git repos cloned, compiled and installed ($1)" >> $LOG_FILE
}

# ----- git compiling + install -------------------
gitinstalls () {
	cd /opt/git/lemonbar-xft
	make
	cd /opt/git/st
	make
	cd /opt/git/suckless_linuxdabbler/dmenu
	make
	cd /opt/git/suckless_linuxdabbler/dwm
	make
	cd /opt/git/dk
	make
	cd /opt/git/bspwm
	make
	sudo make install
	cd /opt/git/sxhkd
	make
	sudo make install
	
	sudo ln -fs /opt/git/lemonbar-xft/lemonbar /usr/local/bin
	sudo ln -fs /opt/git/st/st /usr/local/bin
	sudo ln -fs /opt/git/suckless_linuxdabbler/dwm/dwm /usr/local/bin
	sudo ln -fs /opt/git/suckless_linuxdabbler/dmenu/dmenu /usr/local/bin
	sudo ln -fs /opt/git/suckless_linuxdabbler/dmenu/dmenu_path /usr/local/bin
	sudo ln -fs /opt/git/suckless_linuxdabbler/dmenu/dmenu_run /usr/local/bin
	sudo ln -fs /opt/git/suckless_linuxdabbler/dmenu/stest /usr/local/bin
	sudo ln -fs /opt/git/dk/dk /usr/local/bin
	sudo ln -fs /opt/git/dk/dkcmd /usr/local/bin
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
	echo "bspc rule -a scratch state=floating sticky=on"  >> ~/.config/bspwm/bspwmrc
	echo "xsetroot -cursor_name left_ptr &" >> ~/.config/bspwm/bspwmrc
	echo "compton &" >> ~/.config/bspwm/bspwmrc
	echo "dunst &" >> ~/.config/bspwm/bspwmrc
	cp $ACTUAL_DIR/scratchpad.sh ~/bin
	chmod +x ~/bin/scratchpad.sh
	echo " " >> ~/.config/sxhkd/sxhkdrc
	echo "super + a" >> ~/.config/sxhkd/sxhkdrc
    echo "    /home/$USER/bin/scratchpad.sh" >> ~/.config/sxhkd/sxhkdrc
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] bspwm & sxhkd installed and configured" >> $LOG_FILE
}

# ----- configure dwm -----------------------------
configdwm () {
	cp $ACTUAL_DIR/dwm* ~/bin
	echo "dwm-start" >> .xinitrc
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] dwm configured" >> $LOG_FILE
#
#  ==== patching guide + plus ====
# 
# -- ::notes:: ----
# git branch config       -- this makes a new branch
# git branch              -- list existing branches
# git checkout config     -- changes to this branch
# git branch -D config    -- deletes non-active config branch
# make clean && rm -f config.h && git reset -hard origin/master  -- goes to initial state (no make done), throwing away any potential not commited change
# git merge config -m config  -- merge the contents of config branch into actual branch 
#
# -- starting ---
# git branch config
# git checkout config
# change wethever you want (example: Mod1 -> Mod4)	
# git add config.def.h
# git commit -m config   -- author note (easy way): name of the commentary = name of branch
# git checkout master
# git merge config -m config
#	.. and now we can test if the changes are OK (make & restarting dwm)
#
# -- let's patch pertag: first we want a clean original code again ---
# git checkout master
# make clean && rm -f config.h && git reset -hard origin/master
# git branch pertag
# git checkout pertag
# git apply /location/of/pertag-patch.diff	
#   .. we can see if the changes are applied in the code ...	
# git add .	
# git commit -m pertag	
# git checkout master	
# git merge config -m config	
# git merge pertag -m pertag	-- we merged all changes we did (one by one)
#  ... now we can make and see if the canghes are OK ...	
# 
# -- let's noborder now ---
# git checkout master
# make clean && rm -f config.h && git reset -hard origin/master
# git branch noborder
# git checkout noborder
# git apply /location/of/noborder-patch.diff	
#   .. we can see if the changes are applied in the code ...	
# git add .	
# git commit -m noborder	
# git checkout master	
# git merge config -m config	
# git merge pertag -m pertag
# git merge noborder -m noborder
#	
}

# ----- configure dk -----------------------------
configdk () {
	mkdir -p ~/.config/dk
	mkdir -p ~/.config/sxhkd
	cp /opt/git/dk/doc/scripts/bar.sh ~/bin/bar-dk.sh
	cp /opt/git/dk/doc/dkrc ~/.config/dk/
	cp /opt/git/dk/doc/sxhkdrc ~/.config/sxhkd/sxhkdrc.dk
	chmod +x ~/.config/dk/dkrc
	chmod +x ~/.config/sxhkd/sxhkdrc.dk
	chmod +x ~/bin/dk-bar.sh
	sed -i 's/sxhkd &/sxhkd -c ~\/\.config\/sxhkd\/sxhkdrc\.dk/' ~/.config/dk/dkrc
	sed -i 's/alt/super/' ~/.config/sxhkd/sxhkdrc.dk
	sed -i 's/exit 0/compton &/' ~/.config/dk/dkrc
	echo "dunst &" >> ~/.config/dk/dkrc
	echo "~/bin/dk-bar.sh &" >> ~/.config/dk/dkrc	
	echo "exit 0" >> ~/.config/dk/dkrc
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] dk configured" >> $LOG_FILE
}

# ----- lemonbar panel -----------------------------
lemonbarpanelbsp () {
	cp $ACTUAL_DIR/panel* ~/bin
	cp $ACTUAL_DIR/launch-bar ~/bin
	chmod +x ~/bin/*
	echo "launch-bar &" >> ~/.config/bspwm/bspwmrc
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] lemonbar panel configured" >> $LOG_FILE
}

# ----- wallpaper ----------------------------------
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
	[ -f ~/.config/bspwm/bspwmrc ] && echo "wallpaper-loop &" >> ~/.config/bspwm/bspwmrc
	if [ -f ~/.config/dk/dkrc ]; then
		sed -i 's/exit 0/wallpaper-loop &/' ~/.config/dk/dkrc
		echo "exit 0" >> ~/.config/dk/dkrc
	fi
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] wallpapers downloaded and working" >> $LOG_FILE
}

# ----- xinit & bashrc ----------------------------
finalsetup () {
	sed -i 's/#alias ll=/alias ll=/' ~/.bashrc
	cp $ACTUAL_DIR/choosewm ~/bin
	chmod +x ~/bin/choosewm
	if [ "$WM_SELECTION" = "dwm" ]; then
		echo "dwm-start" >> ~/.xinitrc
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


# ||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||
# ||||||||||||||||||||||||||||||||||||||||


[ -z $OPTION ] && usage

if [ "$OPTION" = "0" ]; then
	WM_SELECTION="all"
	packages && basicfolders && gitrepos && gitrepos bspwm && gitrepos dwm && gitrepos dk && defaultbspwm && lemonbarpanelbsp && configdwm && configdk && walls && finalsetup && echo "bspwm & dwm & dk configured. Please, reboot system."
	echo "bspwm" > $WM_SELECTION_FILE
elif [ "$OPTION" = "1" ]; then
	WM_SELECTION="bspwm"
	packages && basicfolders && gitrepos && gitrepos bspwm && defaultbspwm && lemonbarpanelbsp && walls && finalsetup && echo "bspwm configured. Please, reboot system."
	echo "bspwm" > $WM_SELECTION_FILE
elif [ "$OPTION" = "2" ]; then
	WM_SELECTION="dwm"
	packages && basicfolders && gitrepos && gitrepos dwm && configdwm && walls && finalsetup && echo "dwm configured. Please, reboot system."
	echo "dwm" > $WM_SELECTION_FILE
elif [ "$OPTION" = "3" ]; then
	WM_SELECTION="dk"
	packages && basicfolders && gitrepos && gitrepos dk && configdk && walls && finalsetup && echo "dk configured. Please, reboot system."
	echo "dk" > $WM_SELECTION_FILE
else
	usage
fi
