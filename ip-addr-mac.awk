function dump_addr_mac( addr, mac ) {
	if ( hash ) {
		for ( m in mac ) {
			printf "mac2ip[\"%s\"] = \"%s\"\n", m, addr
		}
	} else {
		printf "%s", addr;
		for ( m in mac ) {
			#printf " %s (%d)",m, mac[m];
			printf " %s",m;
			delete mac[m];
		}
		printf "\n";
	}
}

/^[0-9]++:/ {
	nr = $1 + 0;
	if ( nr < last_nr ) {
		dump_addr_mac( addr, mac )
	}
	last_nr = nr
}

$1 == "link/ether" {
	mac[$2]++;
}

$1 == "inet" {
	addr = gensub ( /^([0-9\.]+).*/, "\\1", "g", $2 )
}

END {
	dump_addr_mac( addr, mac )
}
