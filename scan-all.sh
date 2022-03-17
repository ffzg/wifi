#!/bin/sh -xe

./wap-ips | xargs -i ./wifi-ssh-out {} iw wlan0 scan
./wap-ips | xargs -i ./wifi-ssh-out {} iw wlan1 scan
./wap-ips | xargs -i ./wifi-ssh-out {} ip addr
./wap-ips | xargs -i ./wifi-ssh-out {} iw dev
