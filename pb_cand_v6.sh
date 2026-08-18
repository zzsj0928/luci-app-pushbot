#!/bin/bash
V6_RE='([\da-fA-F0-9]{1,4}(:{1,2})){1,15}[\da-fA-F0-9]{1,4}'
for url in "ip.sb" "api-ipv6.ip.sb/ip" "ident.me" "ifconfig.me" "icanhazip.com" "ipinfo.io/ip" "checkip.amazonaws.com" "v6.ident.me" "api6.ipify.org" "speed.cloudflare.com/__down"; do
	ok=0
	for i in 1 2 3; do
		out=$(curl -k -s -6 -m 8 "$url" 2>/dev/null | grep -oE "$V6_RE" | head -n1)
		[ -n "$out" ] && ok=1
	done
	if [ "$ok" = "1" ]; then echo "PASS  $url"; else echo "FAIL  $url"; fi
done
