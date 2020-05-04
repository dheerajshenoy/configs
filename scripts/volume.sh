#!/usr/bin/sh
#VOL=$(amixer | awk 'NR==6 {print "VOL:" $6 $5}; NR==12 {print "MIC:" $6 $5}' | sed 's/\[/ /g; s/\]//g')

VOL_ICON="0"
VOL=$(amixer | awk 'NR==6 {print $5}' | sed 's/\[/ /g; s/\]//g; s/\%/ /')
VOL_STATUS=$(amixer | awk 'NR==6 {print $6}' | sed 's/\[/ /g; s/\]//g')

if [[ "${VOL_STATUS}" == "off" ]]
then
	VOL_ICON=""
	echo "${VOL_ICON}"
elif [[ "${VOL_STATUS}" == "on" && "${VOL}" -le 100 ]]
then
	VOL_ICON=""
	echo "${VOL_ICON}"
elif [[ "${VOL_STATUS}" == "on" && "${VOL}" -le 70 ]]
then
	VOL_ICON=""
	echo "${VOL_ICON}"
elif [[ "${VOL_STATUS}" == "on" && "${VOL}" -le 40 ]]
then
	VOL_ICON=""
	echo "{$VOL_ICON}"
fi
echo $VOL_STATUS
echo $VOL
