ssh1 root@bnet 'iw dev wlan0 station dump ; iw dev wlan1 station dump' > station.dump
ssh1 root@bnet 'cat /tmp/dhcp.leases' > dhcp.leases
