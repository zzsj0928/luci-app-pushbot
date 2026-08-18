#!/bin/bash
V6_RE='([\da-fA-F0-9]{1,4}(:{1,2})){1,15}[\da-fA-F0-9]{1,4}'
while IFS= read -r url; do
	[ -z "$url" ] && continue
	ok=0
	for i in 1 2 3; do
		out=$(curl -k -s -6 -m 8 "$url" 2>/dev/null | grep -oE "$V6_RE" | head -n1)
		[ -n "$out" ] && ok=1
	done
	if [ "$ok" = "1" ]; then echo "PASS  $url"; else echo "FAIL  $url"; fi
done < /usr/bin/pushbot/api/ipv6.list
