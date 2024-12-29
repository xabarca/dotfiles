#! /bin/sh

ACTUAL_DIR="$(dirname $(readlink -f $0))"

[ -x "$(command -v sudo)" ] && ld="sudo" 
[ -x "$(command -v doas)" ] && [ -e /etc/doas.conf ] && ld="doas"


_st() {
	# st from suckless
	git clone --depth 1  git://git.suckless.org/st /opt/git/st
	cd /opt/git/st || return
	#git apply "$ACTUAL_DIR/../patches/my-own-st-alpha-xresources_20220111.diff"
	git apply "$ACTUAL_DIR/../patches/my-own-st-xresources_20220107.diff"
	git apply "$ACTUAL_DIR/../patches/my-own-st-clipboard_20220107.diff"
	#git apply "$ACTUAL_DIR/../patches/my-own-st-scroll_20220107.diff"
	make 
	$ld ln -sf "$PWD/st" /usr/local/bin
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
			$ld ln -sf "$PWD/$i" /usr/local/bin
		done
		# Crear enlace de manuales de usuario
		for i in *.1; do
			$ld ln -sf "$PWD/$i" /usr/local/share/man/man1/
		done
}

_wmname() {
		# wmname (to be able to start JDK swing applications)
		git clone --depth 1  git://git.suckless.org/wmname /opt/git/wmname
		cd /opt/git/wmname
		$ld make install
}

_dwm() {
	git clone --depth 1  git://git.suckless.org/dwm  /opt/git/dwm
	cd /opt/git/dwm
	sed -i 's/resizehints = 1/resizehints = 0/' /opt/git/dwm/config.def.h
	sed -i 's/#define MODKEY Mod1Mask/#define MODKEY Mod4Mask/' /opt/git/dwm/config.def.h
	make
	$ld ln -fs /opt/git/dwm/dwm /usr/local/bin
	
	cd $ACTUAL_DIR
	mkdir -p $HOME/bin
	cp -r ../dwm* $HOME/bin
	chmod +x $HOME/bin/dwm/*
	echo "~/bin/dwm/dwm-start" >> "$HOME/.xinitrc"
}

_sowm() {
	# wmname (to be able to start JDK swing applications)
	git clone --depth 1  https://github.com/dylanaraps/sowm /opt/git/sowm
	cd /opt/git/sowm
	make
	$ld ln -fs /opt/git/sowm/sowm /usr/local/bin
}


_dmenu
_wmname
_dwm
_st
_sowm

