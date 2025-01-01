#!/bin/sh
#
# Script to launch/focus applications with a keybinding-chain.
#  - If app is launched, it focus it. Otherwise, opens it. Kind of scratchpad.
#  - It is configured in the 'config' function.
#  - The only dependency is: wmctrl
#
#
# Example for use in rc.xml in openbox:
#
#   <keybind key="W-e">
#       <keybind key="1">
#         <action name="Execute">
#             <command>~/bin/openbox_launchy_apps.sh 1</command>
#         </action>
#     </keybind>
#     <keybind key="2">
#         <action name="Execute">
#             <command>~/bin/openbox_launchy_apps.sh 2</command>
#         </action>
#     </keybind>
#     <keybind key="3">
#         <action name="Execute">
#             <command>~/bin/openbox_launchy_apps.sh 3</command>
#         </action>
#     </keybind>
#   </keybind>
#
#
# Example of use in sowm with sxhkd:
#
#   super + e ; {1,2,3}
#    { \
#    ~/bin/openbox_launchy_apps.sh 1, \
#    ~/bin/openbox_launchy_apps.sh 2, \
#    ~/bin/openbox_launchy_apps.sh 3 \
#    }
#


LAUNCHY=/tmp/launchy

config() {
  if [ ! -f "$LAUNCHY"  ]; then
    echo "#NUM  Name  Command/Binary" > $LAUNCHY
    echo "1  Chromium  /opt/appimages/ungoogled-chromium_112.0.5615.121-1.1.AppImage" >> $LAUNCHY
    echo "2  Geany  geany" >> $LAUNCHY
    echo "3  Pcmanfm  pcmanfm" >> $LAUNCHY
    echo "5  xterm  xterm" >> $LAUNCHY
  fi
}

doit() {
  param=$1
  [ -z "$param" ] && exit 2
  conf="$( cat $LAUNCHY | grep -e ^$param )"
  if [ ! -z "$conf"  ]; then
    search=$( echo "$conf" | awk '{print $2}'  )
    binary=$( echo "$conf" | awk '{print $3}'  )
    w="$( wmctrl -lx | grep $search )"
    if [ "$w" = ""  ]; then
      $binary & disown
    else
      id="$(echo "$w" | awk '{print $1}')"
      wmctrl -i -a  $id
    fi
  fi
}
    

#-------------------------------
config
doit $1

