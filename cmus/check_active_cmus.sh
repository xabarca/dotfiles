#!/bin/bash

# checks if cmus is running. If not, sends a signal to bspwm panel bar to 
# actualize the cmus module.

isCmusRunning() {
   echo "$(ps axo comm | grep cmus | wc -l)"
}  

pidfile=/tmp/cmus_module_active
if [ -f "$pidfile" ]; then
   exit 1
else
   #echo "check_active_cmus" > $pidfile
fi


echo "starting $(date '+%H:%m') " >> /tmp/cmus_active

while true; do
   a="$(isCmusRunning)"
   if [ "$a" = "0" ]; then
      $HOME/bin/bspwm/panel/panel update cmus
      #echo "no cmus! $(date '+%H:%m') " >> /tmp/cmus_active
      rm $pidfile
      exit 0
   fi
   #echo "in the bucle .. $(date '+%H:%m') " >> /tmp/cmus_active
   sleep 4s
done

