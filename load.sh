#!/bin/sh

#########################################################
#							#
#							#
#----	Get message when load average is high	    ----#
#							#
#							#
#########################################################


cpu=`cat /proc/cpuinfo | awk '/processor/ {print $3}' | wc -l`

 load1=`cat /proc/loadavg | awk '{print $1}'`
 load2=`cat /proc/loadavg | awk '{print $2}'`
 load3=`cat /proc/loadavg | awk '{print $3}'`



gt1=$(echo "$load1 > $cpu" | bc -q )
gt2=$(echo "$load2 > $cpu" | bc -q )
gt3=$(echo "$load3 > $cpu" | bc -q )

if [ $gt1 -eq 1 ]
then
	
	notify-send  "System's last 1 min. load avg. is $load1 System may be at risk"
	
fi

if [ $gt2 -eq 1 ]
then
        notify-send  "System's last 5 min. load avg. is $load2" 
fi
if [ $gt3 -eq 1 ]
then
        notify-send  "System's  last 15 min. load avg. is $load3" 
fi


