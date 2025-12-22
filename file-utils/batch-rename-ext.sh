#!/bin/bash
# 批量重命名文件扩展名
# 用法: ./batch-rename-ext.sh [目标扩展名]
# 示例: ./batch-rename-ext.sh png  # 将当前目录所有文件扩展名改为 .png

TARGET_EXT="${1:-png}"

for file in *.*; do
    if [ -f "$file" ]; then
        mv "$file" "${file%.*}.$TARGET_EXT"
        echo "已重命名: $file -> ${file%.*}.$TARGET_EXT"
    fi
done

echo "完成! 所有文件已重命名为 .$TARGET_EXT 扩展名"