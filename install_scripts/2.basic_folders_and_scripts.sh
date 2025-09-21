#!/bin/sh

ACTUAL_DIR="$(dirname $(readlink -f $0))"

[ -x "$(command -v sudo)" ] && ld="sudo" 
[ -x "$(command -v doas)" ] && [ -e /etc/doas.conf ] && ld="doas"

# ----- wallpaper ----------------------------------
walls () {
	cd "$HOME/pictures/walls" || return
	wget https://wallpapercave.com/wp/xREMNH6.jpg
	wget https://wallpapercave.com/wp/wp12666467.jpg
	curl -O https://static.simpledesktops.com/uploads/desktops/2017/06/02/bg-wallpaper.png
	curl -O https://static.simpledesktops.com/uploads/desktops/2018/07/29/night.png
	curl -O https://static.simpledesktops.com/uploads/desktops/2018/03/29/ESTRES.png
	curl -O https://static.simpledesktops.com/uploads/desktops/2016/07/19/Path.png
	curl -O https://static.simpledesktops.com/uploads/desktops/2013/02/22/Desktop_Squares.png
	curl -O https://static.simpledesktops.com/uploads/desktops/2014/10/15/tetons-at-night.png
	curl -O https://static.simpledesktops.com/uploads/desktops/2015/03/21/coffee-pixels.png
	curl -O https://static.simpledesktops.com/uploads/desktops/2015/03/02/mountains-on-mars.png
	curl -O https://static.simpledesktops.com/uploads/desktops/2015/02/20/zentree_1.png
	curl -O https://static.simpledesktops.com/uploads/desktops/2013/09/18/wallpaper.png
}


# ----- folders: HOME and /opt/git ---------
basicfolders () {
	for dir in downloads music bin/dwm pictures/walls videos; do
		mkdir -p "$HOME/$dir"
	done
	
	$ld mkdir /opt/AppImage
	$ld chown "$USER:$USER" /opt/AppImage
	if [ ! -d /opt/git ]; then
		$ld mkdir /opt/git
		$ld chown "$USER:$USER" /opt/git
	fi
	
	#cp -r "$ACTUAL_DIR" /opt/git

	cd $ACTUAL_DIR || return
	cd ..
	cp bin/* $HOME/bin
	cp -r dmenu "$HOME/bin"
	chmod u+x "$HOME/bin/*" "$HOME/bin/dmenu/*"
}

basicfolders
walls

