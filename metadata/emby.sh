#!/bin/bash

set -e

EMBY_APIKEY=${EMBY_APIKEY:-e825ed6f7f8f44ffa0563cddaddce14d}
EMBY_ADDR=${EMBY_ADDR:-http://emby:6908}
ALIST_ADDR=${ALIST_ADDR:=http://alist:5678}

EMBY_CONTROL_URL="${EMBY_ADDR/6908/8080}"

MEDIA_DIR="/media"

check_emby_status() {
    curl -s -f -m 5 "${EMBY_ADDR}" > /dev/null
}

save_user_policy() {

    if ! check_emby_status; then
        echo "Emby 服务未启动！"
        return 1
    fi

    echo "保留用户 Policy 中..."
    curl -s "${EMBY_ADDR}/Users?api_key=${EMBY_APIKEY}" > /tmp/emby.response
}

download() {
    if [ -f $MEDIA_DIR/temp/config.mp4 ]; then
        echo "备份旧数据..."
        mv -f $MEDIA_DIR/temp/config.mp4 $MEDIA_DIR/temp/config.mp4.bak
    fi
    echo "下载config.mp4数据..."
    cd $MEDIA_DIR/temp
    # 重试3次下载config.mp4，包含config.mp4.aria2则重试
    for i in {1..5}; do
        echo "下载config.mp4，尝试 $i..."
        aria2c -o config.mp4 --continue=true -x6 --conditional-get=true --allow-overwrite=true "${ALIST_ADDR}/d/元数据/config.mp4"
        if [ ! -f $MEDIA_DIR/temp/config.mp4.aria2 ]; then
            break
        fi
    done

    if [ -f $MEDIA_DIR/temp/config.mp4.aria2 ]; then
        echo "下载config.mp4失败，还原文件..."
        rm -f $MEDIA_DIR/temp/config.mp4.aria2
        rm -f $MEDIA_DIR/temp/config.mp4
        if [ -f $MEDIA_DIR/temp/config.mp4.bak ]; then
            mv -f $MEDIA_DIR/temp/config.mp4.bak $MEDIA_DIR/temp/config.mp4
        fi
        return 1
    fi

    rm -rf $MEDIA_DIR/temp/config.mp4.bak
    return 0
    
}

extract() {
    echo "解压config.mp4数据..."
    cd $MEDIA_DIR/temp
    7z x -aoa -mmt=16 config.mp4
    #删除临时文件config.mp4
    if [ "${CLEAR_TEMP:=false}" = "true" ]; then
    rm -f $MEDIA_DIR/temp/config.mp4
    fi
}

update_data() {

    if check_emby_status; then
        echo "Emby 服务未停止！"
        return 1
    fi

    echo "备份数据中..."
    sqlite3 ${MEDIA_DIR}/config/data/library.db ".dump UserDatas" > /tmp/emby_user.sql
    sqlite3 ${MEDIA_DIR}/config/data/library.db ".dump ItemExtradata" > /tmp/emby_library_mediaconfig.sql
    
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

    echo "更新数据库中..."
    cp -rf $MEDIA_DIR/temp/config/data/library.db* $MEDIA_DIR/config/data/
    sqlite3 $MEDIA_DIR/config/data/library.db "DROP TABLE IF EXISTS UserDatas;"
    sqlite3 $MEDIA_DIR/config/data/library.db ".read /tmp/emby_user.sql"
    sqlite3 $MEDIA_DIR/config/data/library.db "DROP TABLE IF EXISTS ItemExtradata;"
    sqlite3 $MEDIA_DIR/config/data/library.db ".read /tmp/emby_library_mediaconfig.sql"
    echo "保存用户信息完成"
    echo "文件复制中..."
    mkdir -p $MEDIA_DIR/config/cache
    mkdir -p $MEDIA_DIR/config/metadata
    cp -rf $MEDIA_DIR/temp/config/cache/* $MEDIA_DIR/config/cache/
    cp -rf $MEDIA_DIR/temp/config/metadata/* $MEDIA_DIR/config/metadata/
    rm -rf $MEDIA_DIR/temp/config/
    echo "文件复制完成"
    chmod -R 777 $MEDIA_DIR/config/data $MEDIA_DIR/config/cache $MEDIA_DIR/config/metadata
}

wait_for_emby() {
    local MAX_WAIT="300"

    echo "Waiting for Emby service to start at $EMBY_ADDR..."

    while true; do
        local http_code
        http_code=$(curl -s -o /dev/null -w "%{http_code}" "${EMBY_ADDR}/Users")
        if [ "$http_code" -eq 401 ]; then
            echo "Emby service is up and running."
            return 0
        else
            echo "Emby service is not ready yet. HTTP status code: $http_code"
            if [ $MAX_WAIT -le 0 ]; then
                echo "Timeout waiting for Emby service to start."
                return 1
            fi
            sleep 2
            MAX_WAIT=$((MAX_WAIT - 2))
        fi
    done
}

recover_user_policy() {
    echo "更新用户 Policy 中..."
    USER_COUNT=$(jq '.[].Name' /tmp/emby.response | wc -l)
    for ((i = 0; i < USER_COUNT; i++)); do
        id=$(jq -r ".[$i].Id" /tmp/emby.response)
        name=$(jq -r ".[$i].Name" /tmp/emby.response)
        policy=$(jq -r ".[$i].Policy | to_entries | from_entries | tojson" /tmp/emby.response)
        USER_URL_2="${EMBY_ADDR}/Users/$id/Policy?api_key=${EMBY_APIKEY}"
        status_code=$(curl -s -w "%{http_code}" -H "Content-Type: application/json" -X POST -d "$policy" "$USER_URL_2")
        if [ "$status_code" == "204" ]; then
            echo "成功更新 $name 用户Policy"
        else
            echo "返回错误代码 $status_code"
            return 1
        fi
    done
}

stop_emby() {
    echo "停止emby服务..."
    curl -s -f -m 5 "${EMBY_CONTROL_URL}/stop"
    sleep 10
}

start_emby() {
    echo "启动emby服务..."
    curl -s -f -m 5 "${EMBY_CONTROL_URL}/start" || true
    sleep 10
}

update() {
    # 储存用户策略，下载元数据，停止emby服务，更新数据库，启动emby服务，恢复用户策略
    save_user_policy
    download
    extract
    stop_emby
    update_data
    start_emby
    wait_for_emby
    recover_user_policy
}

reset() {
    stop_emby
    if [ ! -f "$MEDIA_DIR/temp/config.mp4" ]; then
        download
    fi
    # 不能删除config目录，该目录下有finished标记文件
    # rm -rf $MEDIA_DIR/config/* 
    cd $MEDIA_DIR
    7z x -aoa -mmt=16 temp/config.mp4
    #删除临时文件config.mp4
    if [ "${CLEAR_TEMP:=false}" = "true" ]; then
    rm -f $MEDIA_DIR/temp/config.mp4
    fi
    start_emby
}

case $1 in
    update)
        update
        ;;
    reset)
        reset
        ;;
    download) 
        download
        ;;
    *)
        echo "Usage: $0 {update|reset|download}"
        exit 1
        ;;
esac
