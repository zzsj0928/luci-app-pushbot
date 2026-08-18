#!/bin/bash
V4_RE='[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'
V6_RE='([\da-fA-F0-9]{1,4}(:{1,2})){1,15}[\da-fA-F0-9]{1,4}'
echo "== IPv4 列表逐个 3 次 =="
while IFS= read -r url; do
	[ -z "$url" ] && continue
	ok=0
	for i in 1 2 3; do
		out=$(curl -k -s -4 -m 8 "$url" 2>/dev/null | grep -oE "$V4_RE" | head -n1)
		[ -n "$out" ] && ok=1
	done
	echo "$ok  $url"
done < /usr/bin/pushbot/api/ipv4.list
echo "== IPv6 列表逐个 3 次 =="
while IFS= read -r url; do
	[ -z "$url" ] && continue
	ok=0
	for i in 1 2 3; do
		out=$(curl -k -s -6 -m 8 "$url" 2>/dev/null | grep -oE "$V6_RE" | head -n1)
		[ -n "$out" ] && ok=1
	done
	echo "$ok  $url"
done < /usr/bin/pushbot/api/ipv6.list
