#!/bin/sh
# Script to run connectiq/simulator and monkeydo
SDK_HOME="$1"
CMD="$2"
BIN="$3"
DEVICE="$4"

# check, please
[ -d "$SDK_HOME" ] || exit 1 ;
[ -n "$CMD" ] || exit 1 ;
if [ -n "$BIN" ]; then
	[ -f "$BIN" ] || exit 1 ;
fi

case "$CMD" in
	sim*|con*)
		sleep 2
		if ! ps aux | grep -v grep | grep "/bin/simulator" > /dev/null ;
		then
			"${SDK_HOME}"bin/connectiq > /dev/null 2>&1 &
		fi;
		sleep 10
		;;
	run|mon*)
		"${SDK_HOME}bin/monkeydo" "$BIN" "$DEVICE" > /dev/null 2>&1 &
		;;
	*)
		;;
esac
exit 0
