#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 VIKINGYFY

#移除luci-app-attendedsysupgrade
sed -i "/attendedsysupgrade/d" $(find ./feeds/luci/collections/ -type f -name "Makefile")
#修改默认主题
sed -i "s/luci-theme-bootstrap/luci-theme-$WRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")
#修改immortalwrt.lan关联IP
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $(find ./feeds/luci/modules/luci-mod-system/ -type f -name "flash.js")
#添加编译日期标识
sed -i "s/(\(luciversion || ''\))/(\1) + (' \/ $WRT_MARK-$WRT_DATE')/g" $(find ./feeds/luci/modules/luci-mod-status/ -type f -name "10_system.js")

WIFI_SH=$(find ./target/linux/{mediatek/filogic,qualcommax}/base-files/etc/uci-defaults/ -type f -name "*set-wireless.sh" 2>/dev/null)
WIFI_UC="./package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc"
if [ -f "$WIFI_SH" ]; then
	#修改WIFI名称
	sed -i "s/BASE_SSID='.*'/BASE_SSID='$WRT_SSID'/g" $WIFI_SH
	#修改WIFI密码
	sed -i "s/BASE_WORD='.*'/BASE_WORD='$WRT_WORD'/g" $WIFI_SH
elif [ -f "$WIFI_UC" ]; then
	#修改WIFI名称
	sed -i "s/ssid='.*'/ssid='$WRT_SSID'/g" $WIFI_UC
	#修改WIFI密码
	sed -i "s/key='.*'/key='$WRT_WORD'/g" $WIFI_UC
	#修改WIFI地区
	sed -i "s/country='.*'/country='CN'/g" $WIFI_UC
	#修改WIFI加密
	sed -i "s/encryption='.*'/encryption='psk2+ccmp'/g" $WIFI_UC
fi

CFG_FILE="./package/base-files/files/bin/config_generate"
#修改默认IP地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $CFG_FILE
#修改默认主机名
sed -i "s/hostname='.*'/hostname='$WRT_NAME'/g" $CFG_FILE

#配置文件修改
echo "CONFIG_PACKAGE_luci=y" >> ./.config
echo "CONFIG_LUCI_LANG_zh_Hans=y" >> ./.config
echo "CONFIG_PACKAGE_luci-theme-$WRT_THEME=y" >> ./.config
echo "CONFIG_PACKAGE_luci-app-$WRT_THEME-config=y" >> ./.config

#引入私有扩展配置
if [ -f "$GITHUB_WORKSPACE/Config/PRIVATE.txt" ]; then
	echo "Applying private configurations from PRIVATE.txt..."
	cat $GITHUB_WORKSPACE/Config/PRIVATE.txt >> ./.config
fi

#手动调整的插件
if [ -n "$WRT_PACKAGE" ]; then
	echo -e "$WRT_PACKAGE" >> ./.config
fi

#无WIFI配置标志
if [[ "${WRT_CONFIG,,}" == *"wifi"* && "${WRT_CONFIG,,}" == *"no"* ]]; then
	echo "WRT_WIFI=wifi-no" >> $GITHUB_ENV
fi

#高通平台调整
DTS_PATH="./target/linux/qualcommax/dts/"
if [[ "${WRT_TARGET^^}" == *"QUALCOMMAX"* ]]; then
	#取消nss相关feed
	echo "CONFIG_FEED_nss_packages=n" >> ./.config
	echo "CONFIG_FEED_sqm_scripts_nss=n" >> ./.config
	#设置NSS版本
	echo "CONFIG_NSS_FIRMWARE_VERSION_12_5=y" >> ./.config
	#其他调整
	echo "CONFIG_PACKAGE_kmod-usb-serial-qualcomm=y" >> ./.config

	#无WIFI配置调整Q6大小
	if [[ "${WRT_CONFIG,,}" == *"wifi"* && "${WRT_CONFIG,,}" == *"no"* ]]; then
		find $DTS_PATH -type f ! -iname '*nowifi*' -exec sed -i 's/ipq\(6018\|8074\).dtsi/ipq\1-nowifi.dtsi/g' {} +
		echo "qualcommax set up nowifi successfully!"
	fi
fi


#airoha平台调整：双 WAN 负载均衡 + IPv6 + board.json
if [[ "${WRT_TARGET^^}" == *"AIROHA"* ]]; then
    echo "=========================================="
    echo "🔧 配置 Airoha 双 WAN 负载均衡（eth1+lan2→LAN, lan3→WAN2, lan4→WAN）"
    echo "=========================================="
    
    mkdir -p ./package/base-files/files/etc/config/
    mkdir -p ./package/base-files/files/etc/
    
    # 生成 network 配置（双 WAN + IPv6）
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
fi
