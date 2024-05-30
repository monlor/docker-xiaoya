#!/bin/bash

set -e

echo "等待元数据下载完成..."
while test ! -f /sync/config/emby_meta_finished; do
    sleep 2
done

echo "检查并创建同步目录..."

dirs=(
    "/sync/xiaoya/每日更新/电视剧,uuLY99gGZ1guQNf2vkxZl9gnBZPGt05TLTk0QQ=="
    "/sync/xiaoya/每日更新/电影,FouyyCCh9FA87nX1vgPDQDgtqxmAaS6+UtkXAw=="
    "/sync/xiaoya/电影/2023,idHchd0CgODoJc6b83N9O78MqrzByHw8DgWK/Q=="
    "/sync/xiaoya/纪录片（已刮削）,iKT0ovILxP3J25ARf3l1zVtg9k6ACie9fZpCvw=="
    "/sync/xiaoya/音乐,3NRc3JTCqv0q9kwxkQuWM7t6jGz/K0fD7Iqy4Q=="
    "/sync/xiaoya/每日更新/动漫,7Q5yvySxbSKvbfcw8TsdIul3RWEGv8K7xQTJwQ=="
    "/sync/xiaoya/每日更新/动漫剧场版,3TMeMJFlG8sbQtaezrEXBwLM05uUi4I56q4qrA=="
)

for line in "${dirs[@]}"; do
    dir=$(echo $line | awk -F, '{print $1}')
    id_base64=$(echo $line | awk -F, '{print $2}')
    if [ ! -d "$dir" ]; then
        echo "创建目录: $dir"
        mkdir -p "$dir"
        chmod -R 777 "$dir"
    fi
    if [ ! -d "$dir/.sync" ]; then
        echo "创建同步目录: $dir/.sync"
        mkdir -p "$dir/.sync"
        chmod -R 777 "$dir/.sync"
    fi
    echo "$id_base64" | base64 -d > "$dir/.sync/ID"
    chmod 777 "$dir/.sync/ID"
done

exec /init