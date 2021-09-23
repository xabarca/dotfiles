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
  echo "     3 : patch dwm"
  echo "     4 : configure hosts file to block trackers"
  echo "     5 : life is easier with browsers"
  echo "     6 : kmonad"
  echo "     7 : xbps-src packges (ungoogled-chromium by marmaduke not included by default)"
  echo "     8 : void-mklive"
  echo " "	
  echo "Check the actions done on the log file: $LOG_FILE"	
  echo " "	
  exit 2
}

# ----- default packages (void) --------
packages_void () {
	# https://notabug.org/reback00/void-goodies
	# https://github.com/ymir-linux/void-packages

# --  faltari algun nopass antes del usuario para no requerir password..... -----
# permit persist visone
# permit visone as root cmd /usr/bin/reboot
# permit visone as root cmd /usr/bin/poweroff
# permit visone as root cmd /usr/bin/halt
# permit visone as root cmd /usr/bin/shutdown args -h now, -r now


	echo "permit nopass keepenv $USER" | sudo tee -a /etc/doas.conf
    sudo chown -c root:root /etc/doas.conf
    sudo chmod -c 0400 /etc/doas.conf
	echo "ignorepkg=linux-firmware-nvidia" | sudo tee -a /etc/xbps.d/00-ignore.conf
	echo "ignorepkg=linux-firmware-amd" | sudo tee -a /etc/xbps.d/00-ignore.conf
	# echo "ignorepkg=linux5.12" | sudo tee -a /etc/xbps.d/00-ignore.conf
	
	sudo xbps-install -Suy xbps
	sudo xbps-install -Suy
	sudo xbps-install -Suy xorg-minimal xinit neovim git bash-completion setxkbmap opendoas
	sudo xbps-remove -y linux-firmware-amd linux-firmware-nvidia
	
# <<<<<<< basesystem 

	sudo xbps-install -y nnn rxvt-unicode dbus xterm
	
	# --- libraries per compilar dmenu / dwm / wmname / st ---
	# sudo xbps-install -y gcc make libX11-devel libXft-devel libXinerama-devel 
	# sudo xbps-install -y pkg-config

	# --- libraries to complie bspwm / sxhkd / dk ---
	# sudo xbps-install -y xcb-util-devel xcb-util-wm-devel xcb-util-cursor-devel xcb-util-keysyms-devel 
	
	sudo xbps-install -y xrandr xdo xdotool curl xwallpaper xrdb xclip jq unzip xsetroot
	#sudo xbps-install -y picom pcmanfm lxappearance archlabs-themes papirus-icon-theme mpv rclone scid_vs_pc
	sudo ln -s /etc/sv/dbus /var/service

	echo "[$(date '+%Y-%m-%d %H:%M.%s')] default packages done" >> $LOG_FILE
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
	echo "! Xresources configs --- " >> "$HOME/.Xresources"
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
	
	sudo xbps-install -Sy fuse qutebrowser python3-adblock
	mkdir -p "$HOME/.config/qutebrowser/themes"
	cd $ACTUAL_DIR || return
	cp qutebrowser/config.py  "$HOME/.config/qutebrowser/"
	cp qutebrowser/xavi.py qutebrowser/nord.py  "$HOME/.config/qutebrowser/themes/"

   	sudo mkdir /opt/LibreWolf
	sudo chown $USER:$USER /opt/LibreWolf
    curl -fLo /opt/LibreWolf/LibreWolf-90.0.2-1.x86_64.AppImage 'https://gitlab.com/librewolf-community/browser/appimage/-/jobs/1450294189/artifacts/raw/LibreWolf-90.0.2-1.x86_64.AppImage'
	chmod +x /opt/LibreWolf/LibreWolf-90.0.2-1.x86_64.AppImage
	sudo ln -fs /opt/LibreWolf/LibreWolf-90.0.2-1.x86_64.AppImage /usr/local/bin/LibreWolf
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] browsers" >> $LOG_FILE
}

# ---------  kmonad  -------------
kmonad () {
	sudo xbps-install -Sy kmonad
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] kmonad" >> $LOG_FILE
}

# ----- dunst  ----------------
notify_dunst () {
	sudo xbps-install -y dunst libnotify
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
	curl -L -O https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Iosevka.zip
	curl -L -O https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/JetBrainsMono.zip
	curl -L -O https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Mononoki.zip
	curl -L -O https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/VictorMono.zip
    # curl -L -o ubuntu.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Ubuntu.zip
	# curl -L -o hack.zip https://github.com/source-foundry/Hack/releases/download/v3.003/Hack-v3.003-ttf.zip
	# curl -L -o awesome-5-15.zip https://github.com/FortAwesome/Font-Awesome/releases/download/5.15.4/fontawesome-free-5.15.4-web.zip 
	# curl -L -o jetbrains.zip https://download.jetbrains.com/fonts/JetBrainsMono-1.0.0.zip?fromGitHub
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
		sudo xbps-install -y gcc make  libX11-devel libXft-devel libXinerama-devel
		# dmenu from suckless
		git clone --depth 1  https://git.suckless.org/dmenu /opt/git/dmenu 
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
		git clone --depth 1  https://git.suckless.org/wmname /opt/git/wmname
		cd /opt/git/wmname
		make
		sudo make install
	fi
	if [ "$1" = "dwm" ]; then
		git clone --depth 1  https://git.suckless.org/dwm  /opt/git/dwm
		cd /opt/git/dwm
		sed -i 's/\"st\"/\"urxvtc\"/' /opt/git/dwm/config.def.h
		sed -i 's/resizehints = 1/resizehints = 0/' /opt/git/dwm/config.def.h
		make
		git clone --depth 1  https://github.com/torrinfail/dwmblocks /opt/git/dwmblocks
		cp $ACTUAL_DIR/blocks.h /opt/git/dwmblocks
		cd /opt/git/dwmblocks
		make
		sudo ln -fs /opt/git/dwm/dwm /usr/local/bin
		sudo ln -fs /opt/git/dwmblocks/dwmblocks /usr/local/bin
		sudo ln -fs /opt/git/dk/dkcmd /usr/local/bin
	fi
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] git repos cloned, compiled and installed ($1)" >> $LOG_FILE
}

# ----- Daemon-less notifications without D-Bus. Minimal and lightweight. -------------------
get_herbe() {
	sudo xbps-install -Suy gcc make libX11-devel libXft-devel libXinerama-devel 
	git clone --depth 1  https://github.com/dudik/herbe /opt/git/herbe
	cd /opt/git/herbe || return
	git apply "$ACTUAL_DIR/patches/herbe-xresources-critical.diff"
	make && strip herbe
	sudo ln -fs "$PWD/herbe" /usr/local/bin
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] herbe repo cloned, installed and patched with Xresources/critical support" >> $LOG_FILE
}

# ----- configure default bspwm -------------------
defaultbspwm () {
	sudo xbps-install -y sxhkd lemonbar-xft bspwm 
	for dir in bspwm sxhkd; do
		mkdir -p "$HOME/.config/$dir"
	done
	cp /usr/share/doc/bspwm/examples/bspwmrc "$HOME/.config/bspwm/"
	cp /opt/git/dotfiles/bspwm/sxhkdrc "$HOME/.config/sxhkd/"
	chmod u+x "$HOME/.config/bspwm/bspwmrc"
	chmod u+x "$HOME/.config/sxhkd/sxhkdrc"
	sed -i 's/urxvt/urxvtc/' "$HOME/.config/sxhkd/sxhkdrc"
	sed -i 's/urxvtcc/urxvtc/' "$HOME/.config/sxhkd/sxhkdrc"
	sed -i 's/super + @space/super + p/' "$HOME/.config/sxhkd/sxhkdrc"
	# scratchpads (using instance name, not class name)
	echo "bspc rule -a \"*:scratchpad\"     sticky=on state=floating"  >> "$HOME/.config/bspwm/bspwmrc"
	echo "bspc rule -a \"*:scratchurxvt\"   sticky=on state=floating"  >> "$HOME/.config/bspwm/bspwmrc"
	echo "bspc rule -a \"*:stmusic\"        sticky=on state=floating"  >> "$HOME/.config/bspwm/bspwmrc"
	echo "xsetroot -cursor_name left_ptr &" >> "$HOME/.config/bspwm/bspwmrc"
	echo "picom &" >> "$HOME/.config/bspwm/bspwmrc"
	echo "# dunst &" >> "$HOME/.config/bspwm/bspwmrc"
	echo "urxvtd -q -o -f &" >> "$HOME/.config/bspwm/bspwmrc"
    echo " " >>"$HOME/.config/sxhkd/sxhkdrc"
	echo "#super + ntilde" >> "$HOME/.config/sxhkd/sxhkdrc"
	echo "#    /home/$USER/bin/scratchpad" >> "$HOME/.config/sxhkd/sxhkdrc"
	lemonbarpanelbsp
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] bspwm & sxhkd installed and configured" >> $LOG_FILE
}

# ----- configure dwm -----------------------------
configdwm () {
	cp -r $ACTUAL_DIR/dwm $HOME/bin/
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
	mkdir -p "$HOME/bin/bspwm"
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
	[ -f ~/.config/bspwm/bspwmrc ] && echo "wallpaper-loop &" >> "$HOME/.config/bspwm/bspwmrc"
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
	cd /opt/git/void-packages  
	./xbps-src binary-bootstrap
		
	# git clone https://github.com/not-void/nvoid /opt/git/nvoid
	# cp -r /opt/git/nvoid/srcpkgs/ungoogled-chromium-marmaduke /opt/git/void-packages/srcpkgs

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
    cp $ACTUAL_DIR/vim/colors/*.vim $HOME/.confit/nvim/colors
	echo "[$(date '+%Y-%m-%d %H:%M.%S')] neovim config done" >> $LOG_FILE
}


# ----- xinit & bashrc ----------------------------
finalsetup () {
	youtube_downloader
	# notify_dunst
	get_herbe
    neovim_config
	cd $ACTUAL_DIR || return
	cat $ACTUAL_DIR/Xresources >> "$HOME/.Xresources"
	cat $ACTUAL_DIR/bashrc >> "$HOME/.bashrc"
	echo "xrdb ~/.Xresources &" >> "$HOME/.xinitrc"
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
	packages_void && basicfolders && fonts && gitrepos \
			&& gitrepos dwm && defaultbspwm && configdwm && walls && finalsetup && echo "bspwm & dwm configured. Please, reboot system."
	echo "bspwm" > $WM_SELECTION_FILE
elif [ "$OPTION" = "1" ]; then
	WM_SELECTION="bspwm"
	packages_void && basicfolders && fonts && gitrepos \
			&& defaultbspwm && walls && finalsetup && echo "bspwm configured. Please, reboot system."
	echo "bspwm" > $WM_SELECTION_FILE
elif [ "$OPTION" = "2" ]; then
	WM_SELECTION="dwm"
	packages_void && basicfolders && fonts && gitrepos \
			&& gitrepos dwm && configdwm && walls && finalsetup && echo "dwm configured. Please, reboot system."
	echo "dwm" > $WM_SELECTION_FILE
elif [ "$OPTION" = "3" ]; then
	patchdwm
elif [ "$OPTION" = "4" ]; then
	updatehosts
elif [ "$OPTION" = "5" ]; then
	browsers
elif [ "$OPTION" = "6" ]; then
	kmonad
elif [ "$OPTION" = "7" ]; then
	void_xbps_src
elif [ "$OPTION" = "8" ]; then
	void_mklive
else
	usage
fi
