/\[wifi.ffzg;/ {
	hostname = gensub ( /^\[wifi.ffzg;([^\]]+).*?$/, "\\1", "g", $1 );
}
$1 == "address" {
	if ( hostname ) {
		if ( hash ) {
			printf "ip2hostname[\"%s\"] = \"%s\"\n", $2, hostname;
		} else {
			printf "%s %s\n", $2, hostname;
		}
	}
	hostname = ""
}
