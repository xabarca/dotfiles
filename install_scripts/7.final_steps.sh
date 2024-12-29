#!/bin/sh

ACTUAL_DIR="$(dirname $(readlink -f $0))"

[ -x "$(command -v sudo)" ] && ld="sudo" 
[ -x "$(command -v doas)" ] && [ -e /etc/doas.conf ] && ld="doas"

# xinitrc
xinit() {
	cat <<EOF > $HOME/.xinitrc
if [ -f \$HOME/.wm ]; then
   wm="\$( cat \$HOME/.wm )"
   case \$wm in
      dwm)
        exec dwm 
        ;;
      bspwm)
        exec bspwm
        ;;
      sowm)
        exec sowm
        ;;
      *)
        echo 'dwm' > \$HOME/.wm
        exec dwm
        ;;
   esac
fi
    
echo 'dwm' > \$HOME/.wm
exec dwm
EOF
	
	echo "[[ \$(ps -e | grep startx) = '' ]] && [[ \$(ps -e | grep tmux) = '' ]] && startx" >> ~/.bash_profile
}


xinit
