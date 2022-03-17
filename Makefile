ip2hostname.awk:
	awk -v hash=1 -f munin-wap-ip-hostname.awk < /etc/munin/munin.conf > ip2hostname.awk

hosts.wap:
	awk -f munin-wap-ip-hostname.awk < /etc/munin/munin.conf | ~/sort-ip.pl > hosts.wap

ip.mac:
	cat out/*addr | awk -f ip-addr-mac.awk > ip.mac

mac2ip.awk:
	cat out/*addr | awk -v hash=1 -f ip-addr-mac.awk > mac2ip.awk
