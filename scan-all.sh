#!/bin/sh -xe

#./wap-ips | xargs -i ./wifi-ssh-out {} iw wlan0 scan
#./wap-ips | xargs -i ./wifi-ssh-out {} iw wlan1 scan

./wap-ips | parallel -j 75 './wifi-ssh-out {} iw wlan0 scan' 
./wap-ips | parallel -j 75 './wifi-ssh-out {} iw wlan1 scan'

#./wap-ips | xargs -i ./wifi-ssh-out {} ip addr
#./wap-ips | xargs -i ./wifi-ssh-out {} iw dev

git -C out commit -m $( date +%Y-%m-%dT%H:%M:%S ) -a
