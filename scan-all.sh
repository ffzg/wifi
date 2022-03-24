#!/bin/sh -xe

#./wap-ips | xargs -i ./wifi-ssh-out {} iw wlan0 scan
#./wap-ips | xargs -i ./wifi-ssh-out {} iw wlan1 scan

if [ -z "$1" ] ; then

./wap-ips | parallel -j 75 './wifi-ssh-out {} iw wlan0 scan' 
./wap-ips | parallel -j 75 './wifi-ssh-out {} iw wlan1 scan'

elif [ "$1" = "dev" ] ; then

#./wap-ips | xargs -i ./wifi-ssh-out {} iw dev
./wap-ips | parallel -j 75 './wifi-ssh-out {} iw dev'

elif [ "$*" = 'uci show' ] ; then

	./wap-ips | parallel -j 75 './wifi-ssh-out {} uci show'

else
	echo "Unsupported command: $*"
	exit 1
fi

#./wap-ips | xargs -i ./wifi-ssh-out {} ip addr

git -C out commit -m $( date +%Y-%m-%dT%H:%M:%S ) -a
