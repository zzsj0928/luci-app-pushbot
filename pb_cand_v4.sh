#!/bin/bash
V4_RE='[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'
for url in "ip.sb" "api.ipify.org" "ifconfig.me/ip" "icanhazip.com" "ident.me" "myip.ipip.net" "ipinfo.io/ip" "checkip.amazonaws.com" "4.ipw.cn" "api-ipv4.ip.sb/ip"; do
	ok=0
	for i in 1 2 3; do
		out=$(curl -k -s -4 -m 8 "$url" 2>/dev/null | grep -oE "$V4_RE" | head -n1)
		[ -n "$out" ] && ok=1
	done
	if [ "$ok" = "1" ]; then echo "PASS  $url -> $out"; else echo "FAIL  $url"; fi
done
