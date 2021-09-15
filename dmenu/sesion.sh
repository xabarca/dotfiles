#! /bin/sh

COLOR=$( $HOME/bin/getcolor grey   )
COLOR_ACCENT=$( $HOME/bin/getcolor white )
COLOR_BG=$( $HOME/bin/getcolor bg )
# SALIR=$(printf " Apagar\\n Reiniciar\\n Bloquear\\n Salir" | dmenu -i -c -l 4 -fn "mononoki:size=9:style=Bold" -nb "#1e1e1e" -nf "#777777" -sb "#1e1e1e" -sf "#ffffff" -p " Sesión:")
SALIR=$(printf " Bloquear\\n Salir\\n Reiniciar\\n Apagar" | dmenu -i -c -l 6 -bw 3 -fn "mononoki:size=19:style=Bold"  -nf "$COLOR"  -sf "$COLOR_ACCENT" -sb "$COLOR" -nb "$COLOR_BG" )
case $SALIR in
	" Apagar") doas poweroff;;
	" Reiniciar") doas reboot;;
	" Bloquear") slock;;
	" Salir") xdotool key "super+shift+e";;
	*) ;;
esac
