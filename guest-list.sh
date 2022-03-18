#!/bin/sh

if [ -z "$1" ] ; then
	./wap-ips | parallel -j 75 $0 | tee /dev/shm/wap.guest.list
	exit 0
fi

ssh -q -i /home/dpavlin/wifi/ssh/wifiadmin -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$1 'echo $( uci get system.@system[0].hostname ) $( uci get wireless.@wifi-iface[3].ssid ) $( uci get wireless.@wifi-iface[3].disabled )' || true
