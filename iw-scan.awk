$1 == "BSS" {
    #MAC = $2
    MAC = gensub ( /([0-9a-fA-F:]+).*?$/, "\\1", "g", $2 );
    wifi[MAC]["enc"] = "Open"
}
$1 == "SSID:" {
    wifi[MAC]["SSID"] = $2
}
$1 == "freq:" {
    wifi[MAC]["freq"] = $NF
}
$1 == "signal:" {
    #wifi[MAC]["sig"] = $2 " " $3
    wifi[MAC]["sig"] = $2
}
$1 == "WPA:" {
    wifi[MAC]["enc"] = "WPA"
}
$1 == "WEP:" {
    wifi[MAC]["enc"] = "WEP"
}

/Authentication suites:/ {
	wifi[MAC]["enc"] = $NF
}

/primary channel/ {
    wifi[MAC]["channel"] = $NF
}

END {
    printf "%17s %-20s %2s %4s %-6s %-10s\n","mac","SSID","ch","Freq","Signal","Encryption"

    for (w in wifi) {
        printf "%17s %-20s %2d %4d %-6s %-10s\n",w,wifi[w]["SSID"],wifi[w]["channel"],wifi[w]["freq"],wifi[w]["sig"],wifi[w]["enc"]
    }
}


