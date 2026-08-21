# ImmortalWrt for Nokia XG-040G-MD (Enhanced Edition)

基于 **ImmortalWrt** 的 Nokia XG-040G-MD 增强固件项目，整合了 naoki66 的 XG2010G/XR1710G 成果。

## 🎯 项目特色

### 核心改进
- ✅ **完整 CPUFreq 支持** — 整合 XR1710G 的 PM-Domain 补丁链
- ✅ **USB 3.0 全功能** — 内核模块完整配置
- ✅ **PON 口管理界面** — 集成 `airoha-xpon-luci`（GPON/XGPON/EPON 认证、OMCI、光模块 DDM）
- ✅ **2.5G LAN + WAN 自动配置** — eth1(EN8811H) 做 LAN，lan4 做 WAN
- ✅ **100+ 内核补丁** — Flow Offload、NPU 加速、PCIe 3.0、PCS/SerDes

### 设备支持
| 型号 | SoC | 内存 | 闪存 | 网口 | PON |
|------|-----|------|------|------|-----|
| Nokia XG-040G-MD | AN7581 | 1GB | 512MB NAND | 1×2.5G + 3×1G | ✅ EN7572 XGSPON |
| Nokia XG-040G-TF | AN7581 | 1GB | 512MB NAND | 1×2.5G + 3×1G | ✅ |
| Nokia XG-140G-MD | AN7581 | 1GB | 512MB NAND | 1×2.5G + 3×1G | ✅ |
| Nokia XG-140G-TF | AN7581 | 1GB | 512MB NAND | 1×2.5G + 3×1G | ✅ |

## 📦 固件特性

### 预装 LuCI 应用
- **PON 管理** — airoha-xpon-luci（认证/业务/OMCI/状态监控）
- **系统工具** — ttyd、watchcat、autoreboot
- **网络工具** — Lucky、UPnP、DDNS
- **主题** — luci-theme-argon（已修复 ucode-mod-math 依赖）

### 技术亮点
1. **CPUFreq 动态调频** — 内核强制注入 `CONFIG_KERNEL_PM=y` + PM-Domain 补丁
2. **USB 完整支持** — 内核强制注入 `CONFIG_KERNEL_USB=y` + XHCI 驱动
3. **PON 口已启用** — DTS 中 `&pon_pcs { status = "okay"; }`
4. **硬件流量卸载** — nft_flow_offload + NPU 加速
5. **PCS/SerDes 驱动** — 支持光模块状态读取与诊断

## 🚀 快速开始

### 下载固件
访问 [Releases 页面](../../releases) 下载最新固件：
- `airoha-an7581-nokia_xg-040g-md-squashfs-sysupgrade.bin` — 标准升级固件
- `airoha-an7581-nokia_xg-040g-md-squashfs-factory.bin` — 原厂刷写固件

### 刷写方法
**从原厂固件刷写：**
```bash
sysupgrade -F -n factory.bin
```

**从 OpenWrt/ImmortalWrt 升级：**
```bash
sysupgrade -n sysupgrade.bin
```

### 默认配置
- **管理地址：** http://192.168.1.1
- **用户名：** root
- **密码：** 无（首次登录后请设置）

## 🛠️ 本地构建

### 依赖安装（Debian/Ubuntu）
```bash
sudo -S -p '' apt update
sudo -S -p '' apt install -y build-essential clang gcc g++ binutils bzip2 gawk gettext git \
  libncurses-dev libssl-dev python3 python3-setuptools rsync unzip wget \
  xsltproc zlib1g-dev file which perl sed make curl
```

### 构建步骤
```bash
# 克隆项目
git clone https://github.com/chkdsk228/ImmortalWrt-XG-040G-Enhanced.git
cd ImmortalWrt-XG-040G-Enhanced

# GitHub Actions 自动构建（推荐）
# 1. Fork 本仓库
# 2. Actions → AIR-ALL → Run workflow

# 本地构建（需要 50GB+ 磁盘空间）
# （需要手动触发 GitHub Actions）
```

## 📋 已知问题与解决方案

### ✅ 已解决问题
| 问题 | 原因 | 解决方案 | commit |
|------|------|----------|--------|
| CPUFreq 显示 N/A | 内核 PM 模块未编译 | 强制注入 `CONFIG_KERNEL_PM=y` 等 8 项 | e3e2f62 |
| USB 不识别 | 内核 USB 模块未编译 | 强制注入 `CONFIG_KERNEL_USB=y` | e3e2f62 |
| LuCI 后台崩溃 | argon 主题缺 `ucode-mod-math` | Config 新增该包 | 34054d2 |
| WAN 口未配置 | 默认全 LAN | uci-defaults 脚本 lan4→WAN | e3e2f62 |

### ⚠️ 待验证功能
- [ ] PON 口光模块识别（需运营商 OLT 配合）
- [ ] NPU 硬件加速实际性能
- [ ] PCIe 设备（原硬件无 PCIe 设备）

## 🙏 致谢

本项目整合了以下开源项目的成果：

| 项目 | 作者 | 贡献 |
|------|------|------|
| [ImmortalWrt](https://github.com/immortalwrt/immortalwrt) | immortalwrt | 上游固件 |
| [ImmortalWrt-for-Gemtek-XR1710G](https://github.com/naoki66/ImmortalWrt-for-Gemtek-XR1710G) | naoki66 | 100+ 内核补丁、CPUFreq 修复 |
| [ImmortalWrt-for-Gemtek-XG2010G](https://github.com/naoki66/ImmortalWrt-for-Gemtek-XG2010G) | naoki66 | XG-040G-MD DTS 支持 |
| [airoha-xpon-luci](https://github.com/naoki66/airoha-xpon-luci) | naoki66 | PON 管理界面 |
| [immortalwrt](https://github.com/bingoguo93/immortalwrt) | bingoguo93 | AN7581 早期移植 |
| [VIKINGYFY/Actions-OpenWrt](https://github.com/VIKINGYFY/Actions-OpenWrt) | VIKINGYFY | GitHub Actions CI 框架 |

## 📜 许可证

- 固件代码：GPL-2.0
- CI 脚本：MIT
- 硬件文档：保留原作者版权

## 🔗 相关链接

- [ImmortalWrt 官方文档](https://immortalwrt.org/)
- [OpenWrt Wiki - AN7581](https://openwrt.org/toh/hwdata/airoha/airoha_an7581)
- [naoki66 的其它 AN7581 项目](https://github.com/naoki66?tab=repositories)
