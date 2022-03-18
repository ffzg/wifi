#!/bin/sh

if [ -z "$1" ] ; then
	./wap-ips | parallel -j 75 $0 | tee /dev/shm/wap.guest.disabled
	sort /dev/shm/wap.guest.disabled > out/wap.guest.disabled
	git -C out commit -m $( date +%Y-%m-%dT%H:%M:%S ) wap.guest.disabled
	exit 0
fi

ssh -q -i /home/dpavlin/wifi/ssh/wifiadmin -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$1 'echo $( uci get system.@system[0].hostname ) $( uci get wireless.@wifi-iface[3].ssid ) $( uci get wireless.@wifi-iface[3].disabled )' || true
