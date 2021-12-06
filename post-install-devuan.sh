#! /bin/sh

ACTUAL_DIR="$(dirname $(readlink -f $0))"
LOG_FILE=~/.post-install.log
WM_SELECTION_FILE=~/.selected_wm
OPTION=$1

# ----- usage ---------
usage()
{
  echo "Configures a default bspwm / dwm desktop from scratch after a minimal netinst system installation. Valid for devuan and void linux."	
  echo " "	
  echo "Usage:  post-install.sh [ option ]"
  echo " "	
  echo "   available values for 'option' parameter:"
  echo "     0 : install and configure all wm available (bspwm & dwm)"
  echo "     1 : install and configure bspwm"
  echo "     2 : install and configure basic dwm"
  echo "     3 : patch dwm"
  echo "     4 : configure hosts file to block trackers"
  echo "     5 : life is easier with browsers"
  echo "     6 : kmonad"
  echo " "	
  echo "Check the actions done on the log file: $LOG_FILE"	
  echo " "	
  exit 2
}

# ----- default packages ---------
packages () {
	sudo apt update 
	sudo apt install --no-install-recommends -y git neovim doas
	sudo apt install --no-install-recommends -y xorg xserver-xorg xdo xdotool xautolock socat xsel xclip
	sudo apt install --no-install-recommends -y libtk8.6
	sudo apt install --no-install-recommends -y xcompmgr curl zip unzip xwallpaper rclone iw rxvt-unicode
	#sudo apt install --no-install-recommends -y pcmanfm lxappearance mpv cmus papirus-icon-theme imagemagick 
	sudo apt install -y elogind
	echo "[$(date '+%Y-%m-%d %H:%M.%s')] default packages done" >> $LOG_FILE
}

# ----- default packages to compile C programs from source  ---------
packages_compile () {
	sudo apt update 
	sudo apt install --no-install-recommends -y gcc make
	sudo apt install --no-install-recommends -y libx11-dev libxft-dev libharfbuzz-dev
	sudo apt install --no-install-recommends -y libpango1.0-dev libx11-xcb-dev libxcb-xinerama0-dev 
	sudo apt install --no-install-recommends -y libxinerama-dev libreadline-dev 
	sudo apt install --no-install-recommends -y libxrandr-dev libimlib2-dev 
	# next two lines are needed only for compile bspwm
	sudo apt install --no-install-recommends -y libxcb-util0-dev libxcb-keysyms1-dev libxcb-randr0-dev libxcb-cursor-dev
	sudo apt install --no-install-recommends -y libxcb-icccm4-dev libxcb-ewmh-dev libxcb-shape0-dev
	echo "[$(date '+%Y-%m-%d %H:%M.%s')]  packages to compile C software done" >> $LOG_FILE
}

# ---- configure no password actions - sudoers -------
conf_doas() {
    echo "permit persist keepenv $USER as root" >> /tmp/doas
   #  username ALL=(ALL) NOPASSWD: /usr/bin/reboot, /usr/bin/poweroff, /usr/bin/shutdown, /usr/bin/halt

    echo "permit nopass $USER as root cmd apt" >> /tmp/doas
    echo "permit nopass $USER as root cmd poweroff" >> /tmp/doas
    echo "permit nopass $USER as root cmd reboot" >> /tmp/doas


    #echo "permit nopass $USER" >> /tmp/doas
    # echo "permit persist $USER" >> /tmp/doas
    # echo "permit nopass $USER as root cnd poweroff" >> /tmp/doas
    #echo "permit nopass $USER as root cnd reboot" >> /tmp/doas
    # echo "permit nopass $USER as root cmd /sbin/reboot" >> /tmp/doas
    # echo "permit nopass $USER as root cmd /sbin/poweroff" >> /tmp/doas
    # echo "permit nopass $USER as root cmd /sbin/halt" >> /tmp/doas
    # echo "permit nopass $USER as root cmd /sbin/shutdown args -h now, -r now" >> /tmp/doas
    sudo cp /tmp/doas /etc/doas.conf
    sudo chown -c root:root /etc/doas.conf
    sudo chmod -c 0400 /etc/doas.conf
	echo "[$(date '+%Y-%m-%d %H:%M.%s')] doas configured" >> $LOG_FILE
}


# ----- folders: HOME and /opt/git ---------
basicfolders () {
	for dir in downloads music bin/dwm pictures/walls videos; do
		mkdir -p "$HOME/$dir"
	done
	
	if [ ! -d /opt/git ]; then
		sudo mkdir /opt/git
		sudo chown "$USER:$USER" /opt/git
		cp -r "$ACTUAL_DIR" /opt/git
	else
		cp -r "$ACTUAL_DIR" /opt/git
	fi
	
	cd $ACTUAL_DIR || return
	cp bin/colors.sh bin/getcolor bin/nnnopen bin/pirokit bin/scratchpad bin/updatehosts bin/vm.sh bin/ytp bin/wallpaper* bin/encpass.sh bin/share "$HOME/bin"
	cp -r dmenu "$HOME/bin"
	chmod u+x "$HOME/bin/*" "$HOME/bin/dmenu/*"
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
	
	sudo apt install -y qutebrowser
	mkdir -p "$HOME/.config/qutebrowser/themes"
	cp $ACTUAL_DIR/qutebrowser/config.py  "$HOME/.config/qutebrowser/"
	cp $ACTUAL_DIR/qutebrowser/xavi.py $ACTUAL_DIR/qutebrowser/nord.py  "$HOME/.config/qutebrowser/themes/"

   	sudo mkdir /opt/LibreWolf
	sudo chown $USER:$USER /opt/LibreWolf
    curl -fLo /opt/LibreWolf/LibreWolf-90.0.2-1.x86_64.AppImage 'https://gitlab.com/librewolf-community/browser/appimage/-/jobs/1450294189/artifacts/raw/LibreWolf-90.0.2-1.x86_64.AppImage'
	chmod +x /opt/LibreWolf/LibreWolf-90.0.2-1.x86_64.AppImage
	sudo ln -fs /opt/LibreWolf/LibreWolf-90.0.2-1.x86_64.AppImage /usr/local/bin/LibreWolf
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] browsers" >> $LOG_FILE
}

# ---------  kmonad  -------------
kmonad () {
	curl -L -o '$HOME/downloads/kmonad' 'https://github.com/kmonad/kmonad/releases/download/0.4.1/kmonad-0.4.1-linux'
	chmod +x "$HOME/downloads/kmonad"
	sudo mv "$HOME/downloads/kmonad" /usr/local/bin	
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] kmonad installed" >> $LOG_FILE
}

# ----- dunst  ----------------
notify_dunst () {
	sudo apt-get install --no-install-recommends dunst libnotify-bin
    [ ! -d '$HOME/.config/dunst' ] && mkdir -p '$HOME/.config/dunst'
	cp $ACTUAL_DIR/dunstrc '$HOME/.config/dunst'
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] dunst configured" >> $LOG_FILE
}

# ----- nerd fonts ---------
fonts() {
	mkdir /tmp/nerdfonts
	cd /tmp/nerdfonts || return
	curl -L -O https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Hack.zip
	curl -L -O https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Ubuntu.zip
#	curl -L -O https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Iosevka.zip
	curl -L -O https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/JetBrainsMono.zip
#	curl -L -O https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Mononoki.zip
	curl -L -O https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/VictorMono.zip
	# curl -L -o hack.zip https://github.com/source-foundry/Hack/releases/download/v3.003/Hack-v3.003-ttf.zip
	# curl -L -o awesome-5-15.zip https://github.com/FortAwesome/Font-Awesome/releases/download/5.15.4/fontawesome-free-5.15.4-web.zip 
	# curl -L -o jetbrains.zip https://download.jetbrains.com/fonts/JetBrainsMono-1.0.0.zip?fromGitHub
	unzip "*.zip"
	rm *Windows*
	sudo mkdir -p /usr/share/fonts/truetype/newfonts
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
		# dmenu from suckless
		git clone --depth 1  git://git.suckless.org/dmenu /opt/git/dmenu 
		cd /opt/git/dmenu || return
		git apply "$ACTUAL_DIR/patches/dmenu-border-20201112-1a13d04.diff"
		git apply "$ACTUAL_DIR/patches/dmenu-center-20200111-8cd37e1.diff"
		make && strip dmenu stest
		for i in dmenu dmenu_* stest; do
			sudo ln -sf "$PWD/$i" /usr/local/bin
		done
		# Crear enlace de manuales de usuario
		for i in *.1; do
			sudo ln -sf "$PWD/$i" /usr/local/share/man/man1/
		done
		# wmname (to be able to start JDK swing applications)
		git clone --depth 1  git://git.suckless.org/wmname /opt/git/wmname
		cd /opt/git/wmname
		make
		sudo make install
		# st - Luke Smith's suckless st fork (patched)
		git clone --depth 1 https://github.com/LukeSmithxyz/st /opt/git/st
		cd /opt/git/st
		make
		sudo ln -fs /opt/git/st/st /usr/local/bin
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
		# slock from suckless
		git clone --depth 1  git://git.suckless.org/slock /opt/git/slock
		cd /opt/git/sxhkd
		git apply "$ACTUAL_DIR/patches/slock-foreground-and-background-20210611-35633d4.diff"
		make
		sudo make install
	fi
	if [ "$1" = "bspwm" ]; then
		git clone --depth 1  https://github.com/baskerville/bspwm /opt/git/bspwm
		cd /opt/git/bspwm
		make
		sudo make install
	elif [ "$1" = "dwm" ]; then
		git clone --depth 1  git://git.suckless.org/dwm  /opt/git/dwm
		cd /opt/git/dwm
		sed -i 's/resizehints = 1/resizehints = 0/' /opt/git/dwm/config.def.h
		make
		git clone --depth 1  https://github.com/torrinfail/dwmblocks /opt/git/dwmblocks
		cp $ACTUAL_DIR/blocks.h /opt/git/dwmblocks
		cd /opt/git/dwmblocks
		make
		sudo ln -fs /opt/git/dwm/dwm /usr/local/bin
		sudo ln -fs /opt/git/dwmblocks/dwmblocks /usr/local/bin
	fi
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] git repos cloned, compiled and installed ($1)" >> $LOG_FILE
}

# ----- Daemon-less notifications without D-Bus. Minimal and lightweight. -------------------
get_herbe() {
	git clone --depth 1  https://github.com/dudik/herbe /opt/git/herbe
	cd /opt/git/herbe || return
	git apply "$ACTUAL_DIR/patches/herbe-xresources-critical.diff"
	make && strip herbe
	sudo ln -fs "$PWD/herbe" /usr/local/bin
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] herbe repo cloned, installed and patched with Xresources/critical support" >> $LOG_FILE
}

# ----- configure default bspwm -------------------
defaultbspwm () {
	for dir in bspwm sxhkd; do
		mkdir -p "$HOME/.config/$dir"
	done
	cp /opt/git/dotfiles/bspwm/bspwmrc "$HOME/.config/bspwm/"
	cp /opt/git/dotfiles/bspwm/sxhkdrc "$HOME/.config/sxhkd/"
	chmod u+x "$HOME/.config/bspwm/bspwmrc"
	chmod u+x "$HOME/.config/sxhkd/sxhkdrc"
	sed -i 's/urxvtc/st/' "$HOME/.config/sxhkd/sxhkdrc"
	sed -i 's/super + @space/super + p/' "$HOME/.config/sxhkd/sxhkdrc"
	# scratchpads (using instance name, not class name)
	echo "bspc rule -a \"*:scratchpad\"     sticky=on state=floating"  >> "$HOME/.config/bspwm/bspwmrc"
	echo "bspc rule -a \"*:scratchurxvt\"   sticky=on state=floating"  >> "$HOME/.config/bspwm/bspwmrc"
	echo "bspc rule -a \"*:scratchxterm\"   sticky=on state=floating"  >> "$HOME/.config/bspwm/bspwmrc"
	echo "bspc rule -a \"*:stmusic\"        sticky=on state=floating"  >> "$HOME/.config/bspwm/bspwmrc"
	echo "xsetroot -cursor_name left_ptr &" >> "$HOME/.config/bspwm/bspwmrc"
	echo "xcompmgr &" >> "$HOME/.config/bspwm/bspwmrc"
	echo "# dunst &" >> "$HOME/.config/bspwm/bspwmrc"
    echo " " >> "$HOME/.config/sxhkd/sxhkdrc"
	echo "#super + ntilde" >> "$HOME/.config/sxhkd/sxhkdrc"
	echo "#    /home/$USER/bin/scratchpad" >> "$HOME/.config/sxhkd/sxhkdrc"
	lemonbarpanelbsp
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] bspwm & sxhkd installed and configured" >> $LOG_FILE
}

# ----- configure dwm -----------------------------
configdwm () {
	cp -r $ACTUAL_DIR/dwm* $HOME/bin
	chmod +x $HOME/bin/dwm/*
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


# ----- lemonbar panel -----------------------------
lemonbarpanelbsp () {
	[ ! -d  "$HOME/bin/bspwm" ] && mkdir -p "$HOME/bin/bspwm"
	cp "$ACTUAL_DIR/bspwm/panel*" "$HOME/bin/bspwm"
	cp "$ACTUAL_DIR/bspwm/launch-bar" "$HOME/bin/bspwm"
	chmod u+x "$HOME/bin/bspwm/*"
	echo '"$HOME/bin/bspwm/launch-bar" &' >> "$HOME/.config/bspwm/bspwmrc"
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] lemonbar panel configured" >> $LOG_FILE
}

# ----- wallpaper ----------------------------------
walls () {
	cd "$HOME/pictures/walls" || return
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
	[ -f ~/.config/bspwm/bspwmrc ] && echo "$HOME/bin/wallpaper-loop &" >> "$HOME/.config/bspwm/bspwmrc"
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] wallpapers downloaded and working" >> $LOG_FILE
}


# ----- configure Xresources -------------------------
xresources() {
    cp -r $ACTUAL_DIR/Xresources $HOME/.config/
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] Xresources configured"  >> $LOG_FILE
}


# ----- configure vim and vim-plug -------------------------
vim_config() {
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    cp $ACTUAL_DIR/vim/vimrc $HOME/.vimrc
    mkdir -p $HOME/.vim/colors
    cp $ACTUAL_DIR/vim/colors/*.vim $HOME/.vim/colors
    echo "[$(date '+%Y-%m-%d %H:%M.%S')] vim config done" >> $LOG_FILE
}

# ----- configure neovim and vim-plug -------------------------
neovim_config() {
	mkdir -p $HOME/.config/nvim/colors
	sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    cp $ACTUAL_DIR/vim/init.vim $HOME/.config/nvim/init.vim
    cp $ACTUAL_DIR/vim/colors/*.vim $HOME/.config/nvim/colors
    echo "[$(date '+%Y-%m-%d %H:%M.%S')] neovim config done" >> $LOG_FILE
}


# ----- xinit & bashrc ----------------------------
finalsetup () {
	youtube_downloader
	# notify_dunst
	xresources
    conf_doas
    get_herbe
    neovim_config
	cd $ACTUAL_DIR || return
	cat $ACTUAL_DIR/bashrc >> "$HOME/.bashrc"
	echo "xrdb ~/.config/Xresources/Xresources &" >> "$HOME/.xinitrc"
	echo "setxkbmap es &" >> "$HOME/.xinitrc"
	if [ "$WM_SELECTION" = "dwm" ]; then
		echo "~/bin/dwm/dwm-start" >> "$HOME/.xinitrc"
	elif [ "$WM_SELECTION" = "bspwm" ]; then
		echo "exec bspwm" >> "$HOME/.xinitrc"
	elif [ "$WM_SELECTION" = "all" ]; then
		echo "if [ -f $WM_SELECTION_FILE ]; then" >> "$HOME/.xinitrc"
		echo "   SEL=\$(cat $WM_SELECTION_FILE)" >> "$HOME/.xinitrc"
		echo "   if [ \$SEL = dwm ]; then"  >> "$HOME/.xinitrc"
		echo "      dwm-start" >>"$HOME/.xinitrc"
		echo "   else" >> "$HOME/.xinitrc"
		echo "      exec bspwm" >> "$HOME/.xinitrc"
		echo "   fi"  >> "$HOME/.xinitrc"
		echo "else"  >> "$HOME/.xinitrc"
		echo "   exec bspwm"  >> "$HOME/.xinitrc"
		echo "fi" >> "$HOME/.xinitrc"
	fi
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] xinitrc & bash alias setups done" >> $LOG_FILE
}

# ----- update /etc/hosts --------------------------
updatehosts() {
	cd $ACTUAL_DIR || return
	cp bin/updatehosts "$HOME/bin/updatehosts"
	chmod +x "$HOME/bin/updatehosts"
	$HOME/bin/updatehosts
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] host update prepared" >> $LOG_FILE
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
      echo "This script is meant to be used in Devuan. Please, try to run the Void Linux one."
      ;;
esac

if [ "$OPTION" = "0" ]; then
	WM_SELECTION="all"
	packages && basicfolders && fonts && packages_compile && gitrepos \
			&& gitrepos bspwm && gitrepos dwm && defaultbspwm && configdwm \
			&& walls && finalsetup && echo "bspwm & dwm configured. Please, reboot system."
	echo "bspwm" > $WM_SELECTION_FILE
elif [ "$OPTION" = "1" ]; then
	WM_SELECTION="bspwm"
	packages && basicfolders && fonts &&  packages_compile &&  gitrepos && gitrepos bspwm && defaultbspwm \
			&& walls && finalsetup && echo "bspwm configured. Please, reboot system."
	echo "bspwm" > $WM_SELECTION_FILE
elif [ "$OPTION" = "2" ]; then
	WM_SELECTION="dwm"
	packages && basicfolders && fonts && packages_compile && gitrepos \
			&& gitrepos dwm && configdwm \
			&& walls && finalsetup && echo "dwm configured. Please, reboot system."
	echo "dwm" > $WM_SELECTION_FILE
elif [ "$OPTION" = "3" ]; then
	patchdwm
elif [ "$OPTION" = "4" ]; then
	updatehosts
elif [ "$OPTION" = "5" ]; then
	browsers
elif [ "$OPTION" = "6" ]; then
	kmonad
else
	usage
fi
