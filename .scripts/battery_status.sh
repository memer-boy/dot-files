# !/bin/bash
. ~/.scripts/entorno

if [ -f $BATTERY_PATH ]; then
	bat_now=`cat $BATTERY_PATH/charge_now`
	bat_full=`cat $BATTERY_PATH/charge_full`

	echo $(((bat_now * 100) / bat_full)) `cat $BATTERY_PATH/status`
else
	echo 100 Charged
fi
