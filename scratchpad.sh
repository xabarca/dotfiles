#! /bin/sh

if id=$(xdo id -N scratch); then
	xdo "$(xprop -id "$id" | awk '/state:/ { if ($3 ~ "Normal") {print "hide"} else {print "show"} }')" -N scratch
else
	st -c scratch -e bash > /dev/null 2>&1 &
fi
