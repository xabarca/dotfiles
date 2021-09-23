#!/bin/sh

cd `dirname $0`

nohup ./check_active_cmus.sh &

~/bin/bspwm/panel/panel update cmus

