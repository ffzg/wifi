#!/bin/sh

if [ -z "$1" ] ; then
	./wap-ips | parallel -j 75 $0
	exit 0
fi

ssh -q -i /home/dpavlin/wifi/ssh/wifiadmin -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$1 "uci set wireless.@wifi-iface[3].disabled='1'; uci set wireless.@wifi-iface[7].disabled='1'; uci commit wireless; wifi"
