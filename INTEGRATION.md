# 整合说明 — Enhanced Edition

## 整合内容

### 1. XR1710G 补丁（naoki66/ImmortalWrt-for-Gemtek-XR1710G）

#### CPUFreq/PM-Domain 补丁（关键修复）
```
patches-6.18/0401-pmdomain-core-support-for-SoC-external-power-domain.patch
patches-6.18/0402-dt-bindings-power-domain-Add-Airoha-EN7581-power-do.patch
patches-6.18/0403-pmdomain-Introduce-driver-to-support-Airoha-EN7581-.patch
patches-6.18/607-arm64-dts-airoha-fix-an7581-cpufreq-probe.patch
```
**作用：** 修复 CPUFreq 显示 N/A 的问题（你之前遇到的核心问题）

#### USB PHY 补丁
```
patches-6.18/220-07-phy-add-driver-for-MediaTek-TPHY-used-on-AN7581.patch
patches-6.18/220-08-dt-bindings-phy-add-MediaTek-TPHY-binding-used-on-.patch
```
**作用：** USB 3.0 完整支持

#### PCS/SerDes 补丁（PON 支持）
```
patches-6.18/310-09-net-pcs-airoha-add-PCS-driver-for-Airoha-AN7581-SoC.patch
patches-6.18/310-10-net-pcs-airoha-add-AN7581-SerDes-USXGMII-mode-sup.patch
```
**作用：** PON 光模块 PCS 层驱动

---

### 2. XG2010G DTS（naoki66/ImmortalWrt-for-Gemtek-XG2010G）

#### 设备树文件
```
dts/an7581-gemtek-xg2010g.dts                      # XG2010G 设备定义
dts/an7581-nokia_xg-040g-md.dts                    # XG-040G-MD 原厂分区
dts/an7581-nokia_xg-040g-md-ubi.dts                # XG-040G-MD UBI 分区
dts/an7581-nokia_xg-040g-md-common.dtsi            # 公共定义
dts/an758x-nokia_xg-040g-common.dtsi               # 跨 SoC 公共定义
dts/an758x-nokia_xg-040g-stock-parts.dtsi          # 原厂分区表
dts/an758x-nokia_xg-040g-ubi-parts.dtsi            # UBI 分区表
```

#### 构建定义
```
image/an7581.mk                                    # 包含 XG-040G-MD 构建目标
```

**关键节点（已启用）：**
```dts
&pon_pcs {
    status = "okay";  // ✅ PON 口已启用
};

&usb0, &usb1 {
    status = "okay";  // ✅ USB 已启用
};
```

---

### 3. airoha-xpon-luci（naoki66/airoha-xpon-luci）

#### LuCI 插件结构
```
package/airoha-xpon-luci/
├── luasrc/controller/xpon.lua          # 路由控制器
├── luasrc/view/xpon/
│   ├── auth.htm                        # 认证页面（LOID/SN/Password）
│   ├── service.htm                     # 业务页面（VLAN 配置）
│   ├── voice.htm                       # 语音页面
│   ├── omci.htm                        # OMCI 调试
│   └── status.htm                      # 状态监控（DDM/FEC/流量）
├── root/usr/bin/
│   ├── xpon-auth-native.sh             # 认证参数下发
│   ├── xpon-apply.sh                   # 配置应用
│   ├── xpon-bind-lan.sh                # LAN 桥接
│   ├── xpon-iptv.sh                    # IPTV 配置
│   ├── xpon-mode                       # PON 模式切换
│   └── pon-multicast                   # 组播工具
└── root/etc/init.d/
    ├── pon-services                    # PON 业务服务
    ├── xpon-app                        # 后台应用
    └── xponconfig                      # 配置持久化
```

**功能清单：**
- ✅ GPON/XGPON/EPON/XGSPON 模式切换
- ✅ LOID/SN/MAC/Password 认证
- ✅ TR069/INTERNET/IPTV/VOICE VLAN 配置
- ✅ 光模块 DDM（收发光功率/dBm/温度/电压）
- ✅ OMCI ME 实体调试
- ✅ FEC 状态与流量统计

---

## 与原项目的差异

| 项目 | 原 OpenWRT-CI-XG-040G-MD | Enhanced Edition |
|------|--------------------------|------------------|
| **补丁来源** | bingoguo93 | **naoki66 XR1710G**（更完整） |
| **CPUFreq** | 主线 607 补丁 | **XR1710G 4 个补丁**（含 PM-Domain） |
| **USB** | 内核强制注入 | **USB PHY 补丁 + 内核注入** |
| **PON 管理** | ❌ 无 | **✅ airoha-xpon-luci** |
| **DTS 来源** | bingoguo93 | **naoki66 XG2010G**（官方支持） |
| **补丁数量** | ~20 | **100+**（Flow Offload/NPU/PCIe） |

---

## 验证清单

### ✅ 已验证（来自原项目）
- [x] 编译通过
- [x] CPUFreq 动态调频（内核强制注入）
- [x] USB 3.0 识别（内核强制注入）
- [x] LuCI 后台稳定（ucode-mod-math 已补）
- [x] WAN 口自动配置（lan4→WAN）

### ⏳ 待验证（需实机测试）
- [ ] PON 口光模块识别（需 OLT）
- [ ] airoha-xpon-luci 认证流程
- [ ] NPU 硬件加速性能
- [ ] Flow Offload 实际效果
- [ ] XR1710G 补丁在 XG-040G-MD 上的兼容性

---

## 构建触发

```bash
# GitHub Actions（推荐）
Actions → AIR-ENHANCED → Run workflow

# 本地测试（仅配置）
Actions → AIR-ENHANCED → Run workflow
└─ 勾选 "仅输出配置文件"
```

---

## 下一步计划

1. **实机验证** — 刷写固件，测试 PON 口与 USB
2. **PON 配置** — 根据运营商 OLT 配置 LOID/SN
3. **性能测试** — NPU 加速与 Flow Offload 实测
4. **文档完善** — 补充 PON 配置指南

---

## 致谢

- **naoki66** — XR1710G/XG2010G/airoha-xpon-luci
- **bingoguo93** — AN7581 早期移植
- **VIKINGYFY** — GitHub Actions CI 框架
- **ImmortalWrt** — 上游固件

---

_本文档记录了 Enhanced Edition 的整合过程与技术细节。_
