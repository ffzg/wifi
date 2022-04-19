#!/bin/sh

if [ -z "$SSID" -o -z "$PASS" ] ; then
	echo "Usage: SSID=FF-GUEST PASS=newpassword $0"
	exit 1
fi

qrencode -o $SSID.png "WIFI:T:WPA;S:$SSID;P:$PASS;;"

