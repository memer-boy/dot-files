# !/bin/bash
. ~/.scripts/entorno

bat_now=`cat $BATTERY_PATH/charge_now`
bat_full=`cat $BATTERY_PATH/charge_full`

echo $(((bat_now * 100) / bat_full)) `cat $BATTERY_PATH/status`
