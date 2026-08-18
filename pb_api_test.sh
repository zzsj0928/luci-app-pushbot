#!/bin/bash
# 对 ipv4.list 每个 API 测试 3 次（与脚本 getip 同参数）
V4_RE='[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'
while IFS= read -r url; do
	[ -z "$url" ] && continue
	ok=0
	for i in 1 2 3; do
		out=$(curl -k -s -4 -m 8 "$url" 2>/dev/null | grep -oE "$V4_RE" | head -n1)
		[ -n "$out" ] && ok=1
	done
	if [ "$ok" = "1" ]; then echo "PASS  $url"; else echo "FAIL  $url"; fi
done < /usr/bin/pushbot/api/ipv4.list
