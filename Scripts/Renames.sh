#!/bin/bash
# 固件重命名脚本

for FILE in *.*; do
    if [[ "$FILE" =~ \.bin$ ]] || [[ "$FILE" =~ \.itb$ ]]; then
        NEW_NAME="${FILE/immortalwrt/enhanced}"
        NEW_NAME="${NEW_NAME/squashfs/squashfs-enhanced}"
        mv -v "$FILE" "$NEW_NAME"
    fi
done

echo "✅ 重命名完成"
