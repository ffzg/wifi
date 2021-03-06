#!/bin/sh

if [ -z "$SSID" -o -z "$PASS" ] ; then
	echo "Usage: SSID=FF-GUEST PASS=newpassword $0"
	exit 1
fi

if [ -z "$1" ] ; then
	./wap-ips | parallel -j 75 $0
	qrencode -o /var/www/wifi/$SSID.png "WIFI:T:WPA;S:$SSID;P:$PASS;;"
	echo "Created QR code for wifi access:"
	ls -al /var/www/wifi/$SSID.png
	echo "http://black.ffzg.hr/wifi/$SSID.png"
	exit 0
fi

ssh -q -i /home/dpavlin/wifi/ssh/wifiadmin -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$1 "uci set wireless.@wifi-iface[3].ssid='${SSID}'; uci set wireless.@wifi-iface[3].key='${PASS}'; uci set wireless.@wifi-iface[3].disabled='0'; uci set wireless.@wifi-iface[7].ssid='${SSID}'; uci set wireless.@wifi-iface[7].key='${PASS}'; uci set wireless.@wifi-iface[7].disabled='0'; uci commit wireless; wifi"
