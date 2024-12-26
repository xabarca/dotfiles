#!/bin/sh

ACTUAL_DIR="$(dirname $(readlink -f $0))"

[ -x "$(command -v sudo)" ] && ld="sudo" 
[ -x "$(command -v doas)" ] && [ -e /etc/doas.conf ] && ld="doas"

# ----- wallpaper ----------------------------------
walls () {
	cd "$HOME/pictures/walls" || return
	wget https://wallpapercave.com/wp/xREMNH6.jpg
	curl -O http://static.simpledesktops.com/uploads/desktops/2013/01/25/enso3.png
	curl -O http://static.simpledesktops.com/uploads/desktops/2018/07/29/night.png
	curl -O http://static.simpledesktops.com/uploads/desktops/2018/03/29/ESTRES.png
	curl -O http://static.simpledesktops.com/uploads/desktops/2016/07/19/Path.png
	curl -O http://static.simpledesktops.com/uploads/desktops/2013/02/22/Desktop_Squares.png
	curl -O http://static.simpledesktops.com/uploads/desktops/2014/10/15/tetons-at-night.png
	curl -O http://static.simpledesktops.com/uploads/desktops/2015/03/21/coffee-pixels.png
	curl -O http://static.simpledesktops.com/uploads/desktops/2015/03/02/mountains-on-mars.png
	curl -O http://static.simpledesktops.com/uploads/desktops/2015/02/20/zentree_1.png
	curl -O http://static.simpledesktops.com/uploads/desktops/2013/09/18/wallpaper.png
}


# ----- folders: HOME and /opt/git ---------
basicfolders () {
	for dir in downloads music bin/dwm pictures/walls videos; do
		mkdir -p "$HOME/$dir"
	done
	
	if [ ! -d /opt/git ]; then
		$ld mkdir /opt/git
		$ld chown "$USER:$USER" /opt/git
		cp -r "$ACTUAL_DIR" /opt/git
	else
		cp -r "$ACTUAL_DIR" /opt/git
	fi
	
	cd $ACTUAL_DIR || return
	cp bin/* $HOME/bin
	cp -r dmenu "$HOME/bin"
	chmod u+x "$HOME/bin/*" "$HOME/bin/dmenu/*"
}

basicfolders
walls

