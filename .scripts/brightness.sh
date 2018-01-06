#!/bin/bash
#. ~/.scripts/entorno

bcur=`xbacklight`
bcur=${bcur%%.*}

if [ $bcur -le 10 ]; then
    binc=1
else
    binc=10
fi

echo $binc

case $1 in
    up)
        xbacklight +$binc
	;;
    down)
        xbacklight -$binc
	;;
esac
