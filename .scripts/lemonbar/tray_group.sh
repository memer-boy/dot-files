#!/bin/bash

# mostrar grupo
function show {
    if [ ! -f /tmp/trayer.pid ]; then
	trayer --widthtype request --align right --edge top --margin 16  --distance 48 &
	echo $! > /tmp/trayer.pid
    fi
}

# ocultar grupo
function hide {
    if [ -f /tmp/trayer.pid ]; then
	kill `cat /tmp/trayer.pid`
	rm /tmp/trayer.pid
    fi
}

# estado
function state {
    if [ -f /tmp/trayer.pid ]; then
	echo "showing"
    else
	echo "hidding"
    fi
}

# toggle
function toggle {
    if [ -f /tmp/trayer.pid ]; then
        hide
    else
	show
    fi
}

case $1 in
    show) show
	  ;;
    hide) hide
	  ;;
    state) state
	   ;;
    toggle) toggle
	    ;;
    *) state
       ;;
esac
