#!/bin/sh

ACTUAL_DIR="$(dirname $(readlink -f $0))"

[ -x "$(command -v sudo)" ] && ld="sudo" 
[ -x "$(command -v doas)" ] && [ -e /etc/doas.conf ] && ld="doas"

# xinitrc
xinit() {
	echo "exec dwm" >> "$HOME/.xinitrc"
	echo "[[ $(ps -e | grep startx) = '' ]] && [[ $(ps -e | grep tmux) = '' ]] && startx" >> ~/.bash_profile
}


xinit
