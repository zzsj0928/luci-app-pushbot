#!/bin/bash
# 部署 luci-app-pushbot r25 到所有第一批终端

TERMINALS="10.1.0.1 10.2.0.1 10.3.0.1 10.12.0.1 10.13.0.1 10.101.0.1 10.102.0.1 10.103.0.1 10.104.0.1"
MAIN_APK="/home/zed/coding/openwrt/luci-app-pushbot/luci-app-pushbot-5.17-r25.apk"
I18N_APK="/home/zed/coding/openwrt/luci-app-pushbot/luci-i18n-pushbot-zh-cn-5.17-r25.apk"

for ip in $TERMINALS; do
    echo "=========================================="
    echo "部署到 $ip"
    echo "=========================================="
    
    # 1. 卸载旧包
    echo "卸载旧包..."
    ssh -F /dev/null root@$ip "apk del luci-i18n-pushbot-zh-cn luci-app-pushbot 2>&1 || true"
    
    # 2. 传输并安装主包
    echo "传输主包..."
    cat $MAIN_APK | ssh -F /dev/null root@$ip "cat > /tmp/luci-app-pushbot.apk"
    echo "安装主包..."
    ssh -F /dev/null root@$ip "apk add --allow-untrusted /tmp/luci-app-pushbot.apk 2>&1 | tail -3"
    
    # 3. 传输并安装 i18n 包
    echo "传输 i18n 包..."
    cat $I18N_APK | ssh -F /dev/null root@$ip "cat > /tmp/luci-i18n.apk"
    echo "安装 i18n 包..."
    ssh -F /dev/null root@$ip "apk add --allow-untrusted /tmp/luci-i18n.apk 2>&1 | tail -3"
    
    # 4. 验证
    echo "验证..."
    ssh -F /dev/null root@$ip "apk info luci-app-pushbot 2>&1 | head -2"
    
    # 5. 清理
    ssh -F /dev/null root@$ip "rm -f /tmp/*.apk"
    
    echo ""
done

echo "=========================================="
echo "部署完成"
echo "=========================================="
