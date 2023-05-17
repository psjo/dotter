#!/bin/sh
# Script to run connectiq/simulator and monkeydo from make
SDK_HOME="$1"

#[ -d "$SDK_HOME" ] || exit 1 ;

case "$2" in
	sim*|con*)
		sleep 2
		if ! ps aux | grep -v grep | grep "/bin/simulator" > /dev/null ; then
			echo "Starting simulator...$SDK_HOME"
			"${SDK_HOME}"bin/connectiq > /dev/null 2>&1 &
		fi
		sleep 10
		;;
	mon*)
		#pkill monkeydo ;
		"${SDK_HOME}bin/monkeydo" "$3" "$4" &
		;;
	*)
		;;
esac
