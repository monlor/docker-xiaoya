#!/bin/bash

set -e

echo "等待元数据下载完成..."
while test ! -f /sync/config/emby_meta_finished; do
    sleep 2
done

echo "检查并创建同步目录..."

dirs=(
    "/sync/xiaoya/每日更新/电视剧"
    "/sync/xiaoya/每日更新/电影"
    "/sync/xiaoya/电影/2023"
    "/sync/xiaoya/纪录片（已刮削）"
    "/sync/xiaoya/音乐"
    "/sync/xiaoya/每日更新/动漫"
    "/sync/xiaoya/每日更新/动漫剧场版"
)

for dir in "${dirs[@]}"; do
    if [ ! -d "$dir" ]; then
        echo "创建目录: $dir"
        mkdir -p "$dir"
    fi
done

/init