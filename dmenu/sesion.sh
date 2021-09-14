#! /bin/sh

# SALIR=$(printf " Apagar\\n Reiniciar\\n Bloquear\\n Salir" | dmenu -i -c -l 4 -fn "mononoki:size=9:style=Bold" -nb "#1e1e1e" -nf "#777777" -sb "#1e1e1e" -sf "#ffffff" -p " Sesión:")
SALIR=$(printf " Apagar\\n Reiniciar\\n Bloquear\\n Salir" | dmenu -i -c -l 4 -bw 2 -fn "VictorMono Nerd Font:size=19:style=Bold"  -nf "#777777"  -sf "#ffffff")
case $SALIR in
	" Apagar") poweroff;;
	" Reiniciar") reboot;;
	" Bloquear") slock;;
	" Salir") xdotool key "super+shift+e";;
	*) ;;
esac
