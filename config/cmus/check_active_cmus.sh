#!/bin/bash

# checks if cmus is running. If not, sends a signal to bspwm panel bar to 
# actualize the cmus module.

CMUS_PID_FILE=/tmp/cmus_module_active

isCmusRunning() {
   echo "$(ps axo comm | grep cmus | wc -l)"
}  

if [ -f "$CMUS_PID_FILE" ]; then
   exit 1
fi


echo "starting $(date '+%H:%m') " >> /tmp/cmus_active

while true; do
   a="$(isCmusRunning)"
   if [ "$a" = "0" ]; then
      $HOME/bin/bspwm/panel/panel update cmus
      #echo "no cmus! $(date '+%H:%m') " >> /tmp/cmus_active
      rm $CMUS_PID_FILE
      exit 0
   fi
   #echo "in the bucle .. $(date '+%H:%m') " >> /tmp/cmus_active
   sleep 4s
done

