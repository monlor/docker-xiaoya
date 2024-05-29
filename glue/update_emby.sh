#!/bin/bash

set -e

EMBY_APIKEY=${EMBY_APIKEY:-e825ed6f7f8f44ffa0563cddaddce14d}
EMBY_URL=${EMBY_URL:-http://emby:8096}
ALIST_ADDR=${ALIST_ADDR:=http://alist:80}

MEDIA_DIR="/media"

curl -s "${EMBY_URL}/Users?api_key=${EMBY_APIKEY}" > /tmp/emby.response

echo "导出数据库中..."
sqlite3 ${MEDIA_DIR}/config/data/library.db ".dump UserDatas" > /tmp/emby_user.sql
sqlite3 ${MEDIA_DIR}/config/data/library.db ".dump ItemExtradata" > /tmp/emby_library_mediaconfig.sql

echo "备份数据中..."
files=(
    "library.db"
    "library.db-shm"
    "library.db-wal"
)
for file in "${files[@]}"; do
    src_file="$MEDIA_DIR/config/data/$file"
    dest_file="$src_file.backup"
    if [ -f "$src_file" ]; then
        if [ -f "$dest_file" ]; then
            rm -f "$dest_file"
        fi
        mv -f "$src_file" "$dest_file"
    fi
done

echo "清理旧数据..."
rm -f $MEDIA_DIR/temp/config.mp4

echo "下载并解压config.mp4数据..."
cd /media/temp
aria2c -o config.mp4 --continue=true -x6 --conditional-get=true --allow-overwrite=true "${ALIST_ADDR}/d/元数据/config.mp4"
7z x -aoa -mmt=16 config.mp4

if sqlite3 $MEDIA_DIR/config/data/library.db ".tables" | grep Chapters3 > /dev/null; then
    cp -f $MEDIA_DIR/temp/config/data/library.db* $MEDIA_DIR/config/data/
    sqlite3 $MEDIA_DIR/config/data/library.db "DROP TABLE IF EXISTS UserDatas;"
    sqlite3 $MEDIA_DIR/config/data/library.db ".read /tmp/emby_user.sql"
    sqlite3 $MEDIA_DIR/config/data/library.db "DROP TABLE IF EXISTS ItemExtradata;"
    sqlite3 $MEDIA_DIR/config/data/library.db ".read /tmp/emby_library_mediaconfig.sql"
    echo "保存用户信息完成"
    echo "文件复制中..."
    mkdir -p $MEDIA_DIR/config/cache
    mkdir -p $MEDIA_DIR/config/metadata
    cp -rf $MEDIA_DIR/temp/config/cache/* $MEDIA_DIR/config/cache/
    cp -rf $MEDIA_DIR/temp/config/cache/* /
    cp -rf $MEDIA_DIR/temp/config/metadata/* $MEDIA_DIR/config/metadata/
    rm -rf $MEDIA_DIR/temp/config/*
    echo "文件复制完成"
    chmod -R 777 \
        $MEDIA_DIR/config/data \
        $MEDIA_DIR/config/cache \
        $MEDIA_DIR/config/metadata
fi

USER_COUNT=$(jq '.[].Name' /tmp/emby.response | wc -l)
for ((i = 0; i < USER_COUNT; i++)); do
    if [[ "$USER_COUNT" -gt 50 ]]; then
        echo "用户超过 50 位，跳过更新用户 Policy！"
        exit 1
    fi
    id=$(jq -r ".[$i].Id" /tmp/emby.response)
    name=$(jq -r ".[$i].Name" /tmp/emby.response)
    policy=$(jq -r ".[$i].Policy | to_entries | from_entries | tojson" /tmp/emby.response)
    USER_URL_2="${EMBY_URL}/Users/$id/Policy?api_key=${EMBY_APIKEY}"
    status_code=$(curl -s -w "%{http_code}" -H "Content-Type: application/json" -X POST -d "$policy" "$USER_URL_2")
    if [ "$status_code" == "204" ]; then
        echo "成功更新 $name 用户Policy"
    else
        echo "返回错误代码 $status_code"
        exit 1
    fi
done