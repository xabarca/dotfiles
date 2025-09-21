#! /bin/bash

logout() {
   cmdOut=''	
   case $(wmctrl -m | grep Name) in
      *Openbox) cmdOut="openbox --exit" ;;
      *JWM) cmdOut="jwm -exit" ;;
      *dwm) cmdCmd="pkill dwm" ;; 
      *) echo "ok" ;;
   esac
   echo "$cmdOut"
}
  
yad --title "Exit" --undecorated --center \
  --button="Log out:0" \
  --button="Lock:1" \
  --button="Reboot:2" \
  --button="Shutdown:3" \
  --button="Cancel:4" \
  
ret=$?

cmd='exit 0'

[[ $ret -eq 0 ]] && cmd="$(echo $(logout))"
[[ $ret -eq 1 ]] && cmd="herbe use slock"
[[ $ret -eq 2 ]] && cmd='systemctl reboot'
[[ $ret -eq 3 ]] && cmd='systemctl poweroff'

exec $cmd
