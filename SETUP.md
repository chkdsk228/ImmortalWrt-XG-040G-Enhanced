# 项目设置指南

## 1. 创建 GitHub 仓库

### 方法 A：GitHub 网页创建（推荐）
1. 访问 https://github.com/new
2. 填写信息：
   - **Repository name**: `ImmortalWrt-XG-040G-Enhanced`
   - **Description**: `Nokia XG-040G-MD 增强固件 — 整合 naoki66 的 XR1710G/XG2010G 补丁与 PON 管理界面`
   - **Public/Private**: Public
   - **不勾选** Initialize this repository with a README
3. 点击 **Create repository**

### 方法 B：使用 gh CLI（如果 token 有权限）
```bash
cd /tmp/xg-040g-enhanced
gh repo create chkdsk228/ImmortalWrt-XG-040G-Enhanced \
  --public \
  --description "Nokia XG-040G-MD 增强固件 — 整合 naoki66 的 XR1710G/XG2010G 补丁与 PON 管理界面"
```

## 2. 推送代码

```bash
cd /tmp/xg-040g-enhanced

# 添加远程仓库
git remote add origin https://github.com/chkdsk228/ImmortalWrt-XG-040G-Enhanced.git

# 推送主分支
git branch -M main
git push -u origin main
```

## 3. 触发首次构建

### 方法 A：GitHub 网页触发
1. 访问你的仓库
2. 点击 **Actions** 标签
3. 左侧选择 **AIR-ENHANCED**
4. 点击右上角 **Run workflow** → **Run workflow**

### 方法 B：使用 gh CLI
```bash
gh workflow run AIR-ENHANCED.yml --repo chkdsk228/ImmortalWrt-XG-040G-Enhanced
```

## 4. 监控构建进度

```bash
# 查看最新的 workflow run
gh run list --repo chkdsk228/ImmortalWrt-XG-040G-Enhanced --limit 1

# 查看构建日志
gh run view --repo chkdsk228/ImmortalWrt-XG-040G-Enhanced --log
```

## 5. 下载固件

构建完成后：
1. 访问 https://github.com/chkdsk228/ImmortalWrt-XG-040G-Enhanced/releases
2. 下载最新的 Release

或使用 CLI：
```bash
gh release list --repo chkdsk228/ImmortalWrt-XG-040G-Enhanced
gh release download --repo chkdsk228/ImmortalWrt-XG-040G-Enhanced
```

## 6. 项目结构说明

```
ImmortalWrt-XG-040G-Enhanced/
├── .github/workflows/
│   ├── AIR-ENHANCED.yml          # 主 workflow（手动触发）
│   ├── WRT-CORE-ENHANCED.yml     # 核心构建逻辑（整合补丁）
│   ├── AIR-ALL.yml               # 原项目 workflow（保留）
│   └── Auto-Clean.yml            # 自动清理（7天）
├── Config/
│   ├── AIROHA-ENHANCED.txt       # 增强配置（新）
│   ├── AIROHA-WIFI-NO.txt        # 原配置（保留）
│   └── GENERAL.txt               # 通用配置
├── Scripts/
│   ├── Settings.sh               # 系统设置
│   ├── Packages.sh               # 插件管理
│   ├── Handles.sh                # 额外处理
│   └── Renames.sh                # 固件重命名（新）
├── README.md                     # 项目说明
├── INTEGRATION.md                # 整合文档（新）
└── SETUP.md                      # 本文件

```

## 7. 核心差异（相比原项目）

| 组件 | 原项目 | 增强版 |
|------|--------|--------|
| **CPUFreq 补丁** | bingoguo93 主线 | **naoki66 XR1710G（4个补丁）** |
| **USB 补丁** | 内核注入 | **USB PHY 补丁 + 内核注入** |
| **PON 管理** | ❌ | **✅ airoha-xpon-luci** |
| **DTS 来源** | bingoguo93 | **naoki66 XG2010G** |
| **补丁下载** | Borrow 脚本 | **自动下载 XR1710G/XG2010G** |
| **构建 workflow** | WRT-CORE.yml | **WRT-CORE-ENHANCED.yml** |

## 8. 故障排查

### 构建失败
1. 检查 Actions 日志中的错误信息
2. 常见问题：
   - 补丁下载 404 → XR1710G/XG2010G 仓库更新了文件路径
   - 编译错误 → 上游 ImmortalWrt 主线变动
   - 缓存问题 → 手动清理 Actions 缓存

### token 权限不足
```bash
# 检查当前 token 权限
gh auth status

# 重新登录（选择所有权限）
gh auth login
```

## 9. 后续更新

同步你的原项目最新提交：
```bash
cd /tmp
git clone https://github.com/chkdsk228/OpenWRT-CI-XG-040G-MD.git old
git clone https://github.com/chkdsk228/ImmortalWrt-XG-040G-Enhanced.git new

cd new
# 复制更新的脚本/配置
cp ../old/Scripts/*.sh Scripts/
cp ../old/Config/*.txt Config/

git add -A
git commit -m "sync: Update from original project"
git push
```

## 10. 贡献上游

如果 Enhanced Edition 验证成功，可以考虑：
1. 给 naoki66 提 Issue 反馈 XG-040G-MD 测试结果
2. 给 ImmortalWrt 提 PR（如果发现新问题的修复）
3. 完善 PON 配置文档（给其他用户参考）

---

**下一步：按照步骤 1-3 创建仓库并触发首次构建。**
