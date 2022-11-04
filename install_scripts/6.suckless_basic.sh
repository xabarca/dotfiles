#! /bin/sh

ACTUAL_DIR="$(dirname $(readlink -f $0))"


_packages_compile () {
	sudo apt update 
	sudo apt install --no-install-recommends -y gcc make
	sudo apt install --no-install-recommends -y libx11-dev libxft-dev libharfbuzz-dev
	sudo apt install --no-install-recommends -y libpango1.0-dev libx11-xcb-dev libxcb-xinerama0-dev 
	sudo apt install --no-install-recommends -y libxinerama-dev libreadline-dev 
	sudo apt install --no-install-recommends -y libxrandr-dev libimlib2-dev libxpm-dev
	# next two lines are needed only for compile bspwm
	# sudo apt install --no-install-recommends -y libxcb-util0-dev libxcb-keysyms1-dev libxcb-randr0-dev libxcb-cursor-dev
	# sudo apt install --no-install-recommends -y libxcb-icccm4-dev libxcb-ewmh-dev libxcb-shape0-dev
}

_st() {
	# st from suckless
	git clone --depth 1  git://git.suckless.org/st /opt/git/st
	cd /opt/git/st || return
	git apply "$ACTUAL_DIR/../patches/my-own-st-alpha-xresources_20220111.diff"
	git apply "$ACTUAL_DIR/../patches/my-own-st-clipboard_20220107.diff"
	git apply "$ACTUAL_DIR/../patches/my-own-st-scroll_20220107.diff"
	make 
	sudo ln -sf "$PWD/st" /usr/local/bin
}

_dmenu() {
		# dmenu from suckless
		git clone --depth 1  git://git.suckless.org/dmenu /opt/git/dmenu 
		cd /opt/git/dmenu || return
		git apply "$ACTUAL_DIR/../patches/dmenu-border-20201112-1a13d04.diff"
		git apply "$ACTUAL_DIR/../patches/dmenu-center.diff"
		git apply "$ACTUAL_DIR/../patches/dmenu-password.diff"
		make && strip dmenu stest
		for i in dmenu dmenu_* stest; do
			sudo ln -sf "$PWD/$i" /usr/local/bin
		done
		# Crear enlace de manuales de usuario
		for i in *.1; do
			sudo ln -sf "$PWD/$i" /usr/local/share/man/man1/
		done
}

_wmname() {
		# wmname (to be able to start JDK swing applications)
		git clone --depth 1  git://git.suckless.org/wmname /opt/git/wmname
		cd /opt/git/wmname
		sudo make install
}

_dwm() {
	git clone --depth 1  git://git.suckless.org/dwm  /opt/git/dwm
	cd /opt/git/dwm
	sed -i 's/resizehints = 1/resizehints = 0/' /opt/git/dwm/config.def.h
	sed -i 's/#define MODKEY Mod1Mask/#define MODKEY Mod4Mask/' /opt/git/dwm/config.def.h
	make
	sudo ln -fs /opt/git/dwm/dwm /usr/local/bin
	
	cd $ACTUAL_DIR
	mkdir -p $HOME/bin
	cp -r ../dwm* $HOME/bin
	chmod +x $HOME/bin/dwm/*
	echo "~/bin/dwm/dwm-start" >> "$HOME/.xinitrc"
}

_packages_compile
_dmenu
_wmname
_dwm
_st

