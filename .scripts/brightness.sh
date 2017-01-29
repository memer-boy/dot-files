#!/bin/bash
. ~/.scripts/entorno

bmax=`cat /sys/class/backlight/intel_backlight/max_brightness`
binc=$((bmax / 20))
bcur=`cat /sys/class/backlight/intel_backlight/brightness`

case $1 in
    up)
	next=$((bcur + binc))
	if [ $next -gt $bmax ]; then
	    next=$bmax
	fi
        echo $next > /sys/class/backlight/intel_backlight/brightnes
	;;
    down)
	next=$((bcur - binc))
	if [ $next -lt 0 ]; then
	    next=0
	fi
        echo $next > /sys/class/backlight/intel_backlight/brightnes
	;;
esac
