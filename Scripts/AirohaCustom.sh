#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 chkdsk228
# 自研定制: Airoha 双 WAN 负载均衡 + IPv6 + board.json
# 由 WRT-CORE-ENHANCED.yml 在 Custom Settings 阶段 (Settings.sh 之后) 调用
# 不参与上游 sync (上游无此文件)

# 仅 Airoha 平台生效
if [[ "${WRT_TARGET^^}" != *"AIROHA"* ]]; then
    echo "跳过 Airoha 定制 (非 Airoha 平台)"
    exit 0
fi

echo "=========================================="
echo "🔧 配置 Airoha 双 WAN 负载均衡（eth1+lan2→LAN, lan3→WAN2, lan4→WAN）"
echo "=========================================="

mkdir -p ./package/base-files/files/etc/config/
mkdir -p ./package/base-files/files/etc/

# 生成 network 配置（双 WAN + IPv6）— 静态文件优先于 board.d 重新生成
cat > ./package/base-files/files/etc/config/network << 'NETWORK_EOF'
config interface 'loopback'
    option device 'lo'
    option proto 'static'
    option ipaddr '127.0.0.1'
    option netmask '255.0.0.0'

config globals 'globals'
    option ula_prefix 'auto'

config device
    option name 'br-lan'
    option type 'bridge'
    list ports 'eth1'
    list ports 'lan2'

config interface 'lan'
    option device 'br-lan'
    option proto 'static'
    option ipaddr '192.168.1.1'
    option netmask '255.255.255.0'
    option ip6assign '60'

config interface 'wan'
    option device 'lan4'
    option proto 'dhcp'
    option metric '10'

config interface 'wan6'
    option device 'lan4'
    option proto 'dhcpv6'
    option reqaddress 'try'
    option reqprefix 'auto'

config interface 'wan2'
    option device 'lan3'
    option proto 'dhcp'
    option metric '20'

config interface 'wan2_6'
    option device 'lan3'
    option proto 'dhcpv6'
    option reqaddress 'try'
    option reqprefix 'auto'
NETWORK_EOF

sed -i "s/192\\.168\\.1\\.1/$WRT_IP/g" ./package/base-files/files/etc/config/network

# 生成 board.json（修复 LED 和 Web 界面显示）
cat > ./package/base-files/files/etc/board.json << 'BOARDJSON_EOF'
{
	"model": {
		"id": "nokia,xg-040g-md",
		"name": "Nokia Bell XG-040G-MD"
	},
	"led": {
		"eth1": {
			"name": "eth1 (2.5G)",
			"sysfs": "mt7530-0:0f:green:lan-1",
			"type": "netdev",
			"device": "eth1",
			"mode": "link tx rx"
		},
		"lan2": {
			"name": "lan2",
			"sysfs": "mt7530-0:0a:green:lan-2",
			"type": "netdev",
			"device": "lan2",
			"mode": "link tx rx"
		},
		"lan3": {
			"name": "lan3",
			"sysfs": "mt7530-0:0b:green:lan-3",
			"type": "netdev",
			"device": "lan3",
			"mode": "link tx rx"
		},
		"lan4": {
			"name": "lan4",
			"sysfs": "mt7530-0:0c:green:lan-4",
			"type": "netdev",
			"device": "lan4",
			"mode": "link tx rx"
		}
	},
	"network": {
		"lan": {
			"ports": [
				"eth1",
				"lan2"
			],
			"protocol": "static"
		},
		"wan": {
			"device": "lan4",
			"protocol": "dhcp"
		},
		"wan2": {
			"device": "lan3",
			"protocol": "dhcp"
		}
	}
}
BOARDJSON_EOF

echo "✅ Airoha 双 WAN 网络配置完成"
echo "   - LAN: eth1 (2.5G) + lan2"
echo "   - WAN: lan4 (metric 10, IPv4+IPv6)"
echo "   - WAN2: lan3 (metric 20, IPv4+IPv6)"
echo "   - LED: eth1/lan2/lan3/lan4 已绑定"