#!/bin/bash
# 推送脚本 — 请先在 GitHub 网页创建仓库

REPO_URL="https://github.com/chkdsk228/ImmortalWrt-XG-040G-Enhanced.git"

echo "========================================"
echo "🚀 准备推送到 GitHub"
echo "========================================"
echo ""
echo "仓库地址: $REPO_URL"
echo ""
echo "⚠️  请先确认已在 GitHub 网页创建了空仓库："
echo "   https://github.com/new"
echo ""
read -p "已创建？按回车继续..." 

git remote add origin "$REPO_URL" 2>/dev/null || git remote set-url origin "$REPO_URL"
git branch -M main

echo ""
echo "📤 推送中..."
git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 推送成功！"
    echo ""
    echo "下一步："
    echo "1. 访问 Actions: https://github.com/chkdsk228/ImmortalWrt-XG-040G-Enhanced/actions"
    echo "2. 选择 AIR-ENHANCED workflow"
    echo "3. 点击 Run workflow 触发构建"
else
    echo ""
    echo "❌ 推送失败，请检查："
    echo "- 仓库是否已创建"
    echo "- GitHub token 是否有 push 权限"
    echo "- 网络连接是否正常"
fi
