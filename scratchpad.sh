#! /bin/sh

# in bspwm, we have to stablish a rule like this:  
#     bspc rule -a "*:scratchpad"  sticky=on state=floating
# tp mach every scratchpad name we wanna use
SCRATCHPAD_NAME=$1
[ -z $SCRATCHPAD_NAME ] && SCRATCHPAD_NAME="scratchpad"


# if id=$(xdo id -N scratch); then
# 	xdo "$(xprop -id "$id" | awk '/state:/ { if ($3 ~ "Normal") {print "hide"} else {print "show"} }')" -N scratch
# else
# 	st -c scratch -e bash > /dev/null 2>&1 &
# fi


if [ "$SCRATCHPAD_NAME" = "st_scratchpad" ]; then
	# we decide that name "scratchpad" will be launched as an st
	xdotool search --onlyvisible --classname $SCRATCHPAD_NAME windowunmap \
      || xdotool search --classname $SCRATCHPAD_NAME windowmap \
      || st -n $SCRATCHPAD_NAME -f Hack-9 &
else
	# else, we launch urxvtc
	xdotool search --onlyvisible --classname $SCRATCHPAD_NAME windowunmap \
      || xdotool search --classname $SCRATCHPAD_NAME windowmap \
      || urxvtc -name $SCRATCHPAD_NAME &
fi
