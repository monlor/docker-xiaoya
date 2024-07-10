#!/bin/bash

set -e

ALIST_ADDR=${ALIST_ADDR:-http://alist:5678}

echo "检查alist连通性..."
while ! curl -s --fail "${ALIST_ADDR}/api/public/settings" | grep -q 200; do
    sleep 2
done

echo "alist启动完成，等待10秒后开始下载元数据..."
sleep 10

MEDIA_DIR="/media"
crontabs=""

if [ ! -d "${MEDIA_DIR}/temp" ]; then
    mkdir -p "${MEDIA_DIR}/temp"
fi
if [ ! -d "${MEDIA_DIR}/xiaoya" ]; then
    mkdir -p "${MEDIA_DIR}/xiaoya"
fi
if [ ! -d "${MEDIA_DIR}/config" ]; then
    mkdir -p "${MEDIA_DIR}/config"
fi

echo "开始下载元数据，如果有问题无法解决，请删除目录 ${MEDIA_DIR}/temp 下的所有文件重新启动."

disk_check() {
    if [ "${DISK_CHECK_ENABLED:-true}" = "false" ]; then
        return
    fi
    # 磁盘检测
    dir="$1"
    size="$2"
    free_size=$(df -P "${dir}" | tail -n1 | awk '{print $4}')
    free_size=$((free_size))
    free_size_G=$((free_size / 1024 / 1024))
    if [ $free_size_G -lt "${size}" ]; then
        echo "目录${dir}最少需要剩余空间：${size}G，目前仅剩：${free_size_G}G"
        exit 1
    fi
}  

download_meta() {
    file=$1
    # 元数据路径
    path=${2:-}
    echo "Downloading ${file}..."
    # 检查历史文件，如果存在残留则删除
    if [ -f "${MEDIA_DIR}/temp/${file}.aria2" ]; then
        echo "Found ${file}.aria2, delete it."
        rm -rf "${MEDIA_DIR}/temp/${file}.aria2"
        rm -rf "${MEDIA_DIR}/temp/${file}"
    fi

    # 如果已经存在文件，则不下载
    if [ -f "${MEDIA_DIR}/temp/${file}" ]; then
        echo "Found ${file}, skip."
        return
    fi

    # 重试5次下载，包含.aria2则重试
    success=false
    for i in {1..5}; do
        echo "Downloading ${file}, try ${i}..."
        echo "Link is ${ALIST_ADDR}/d/元数据/${file}"
        if aria2c -o "${file}" --allow-overwrite=true --auto-file-renaming=false --enable-color=false -c -x6 "${ALIST_ADDR}/d/元数据/${path}${file}"; then
            # 下载的文件小于10M，下载失败，删除
            if [ "$(stat -c %s "${file}")" -lt 10000000 ]; then
                echo "Download ${file} failed, file size less than 10M, retry after 10 seconds."
                rm -rf "${file}"
                rm -rf "${file}.aria2"
                sleep 10
                continue
            fi
            # 下载成功
            success=true
            break
        fi
    done
    # 如果还存在aria2
    if [ "${success}" = "false" ]; then
        echo "Download ${file} failed."
        rm -rf "${file}"
        rm -rf "${file}.aria2"
        return 1
    fi
}

download_emby_config() {
    if [ -f ${MEDIA_DIR}/config/emby_meta_finished ]; then
        echo "Emby metadata has been downloaded. Delete the file ${MEDIA_DIR}/config/emby_meta_finished to re-extract."
        return
    fi

    disk_check ${MEDIA_DIR}/temp 5
    disk_check ${MEDIA_DIR}/config 5 

    echo "Downloading Emby config..."

    cd "${MEDIA_DIR}/temp"
    download_meta config.mp4

    echo "Extracting Emby config..."

    cd ${MEDIA_DIR}
    7z x -aoa -mmt=16 temp/config.mp4

    touch ${MEDIA_DIR}/config/emby_meta_finished

    #删除临时文件config.mp4
    if [ "${CLEAR_TEMP:=false}" = "true" ]; then
        rm -f $MEDIA_DIR/temp/config.mp4
    fi
}

download_emby_media() {    
    if [ -f "${MEDIA_DIR}/xiaoya/emby_media_finished" ]; then
        echo "Emby media has been downloaded. Delete the file ${MEDIA_DIR}/xiaoya/emby_media_finished to re-extract."
        return
    fi

    echo "Cleaning up Emby media..."
    rm -rf ${MEDIA_DIR}/xiaoya/*

    disk_check ${MEDIA_DIR}/temp 60
    disk_check ${MEDIA_DIR}/xiaoya 70
    
    echo "Downloading Emby media..."

    cd "${MEDIA_DIR}/temp"
    download_meta all.mp4
    download_meta pikpak.mp4

    echo "Extracting Emby media..."

    cd ${MEDIA_DIR}/xiaoya
    7z x -aoa -mmt=16 ${MEDIA_DIR}/temp/all.mp4

    cd ${MEDIA_DIR}/xiaoya
    7z x -aoa -mmt=16 ${MEDIA_DIR}/temp/pikpak.mp4

    chmod -R 777 ${MEDIA_DIR}/xiaoya

    touch ${MEDIA_DIR}/xiaoya/emby_media_finished

    #删除临时文件all.mp4,pikpak.mo4
    if [ "${CLEAR_TEMP:=false}" = "true" ]; then
        rm -f $MEDIA_DIR/temp/all.mp4
        rm -f $MEDIA_DIR/temp/pikpak.mp4
    fi
}

download_jellyfin_config() {
    if [ -f ${MEDIA_DIR}/jf_config/jellyfin_meta_finished ]; then
        echo "Jellyfin metadata has been downloaded. Delete the file ${MEDIA_DIR}/jf_config/jellyfin_meta_finished to re-extract."
        return
    fi

    disk_check ${MEDIA_DIR}/temp 5
    disk_check ${MEDIA_DIR}/jf_config 20

    echo "Downloading Jellyfin config..."

    cd ${MEDIA_DIR}/temp
    download_meta config_jf.mp4 Jellyfin/
    
    echo "Extracting Jellyfin config..."

    cd ${MEDIA_DIR}
    7z x -aoa -mmt=16 temp/config_jf.mp4

    touch ${MEDIA_DIR}/jf_config/jellyfin_meta_finished

    #删除临时文件 config_jf.mp4
    if [ "${CLEAR_TEMP:=false}" = "true" ]; then
        rm -f $MEDIA_DIR/temp/config_jf.mp4
    fi
}

download_jellyfin_media() {    
    if [ -f "${MEDIA_DIR}/jf_xiaoya/jellyfin_media_finished" ]; then
        echo "Jellyfin media has been downloaded. Delete the file ${MEDIA_DIR}/jf_xiaoya/jellyfin_media_finished to re-extract."
        return
    fi

    echo "Cleaning up Jellyfin media..."
    rm -rf ${MEDIA_DIR}/jf_xiaoya/*

    disk_check ${MEDIA_DIR}/temp 60
    disk_check ${MEDIA_DIR}/jf_xiaoya 70
    
    echo "Downloading Jellyfin media..."

    cd "${MEDIA_DIR}/temp"
    download_meta all_jf.mp4 Jellyfin/
    download_meta PikPak_jf.mp4 Jellyfin/

    echo "Extracting Jellyfin media..."

    cd ${MEDIA_DIR}/jf_xiaoya
    7z x -aoa -mmt=16 ${MEDIA_DIR}/temp/all_jf.mp4

    cd ${MEDIA_DIR}/jf_xiaoya
    7z x -aoa -mmt=16 ${MEDIA_DIR}/temp/PikPak_jf.mp4

    chmod -R 777 ${MEDIA_DIR}/jf_xiaoya

    touch ${MEDIA_DIR}/jf_xiaoya/jellyfin_media_finished

    #删除临时文件all_jf.mp4,pikpak_jf.mo4
    if [ "${CLEAR_TEMP:=false}" = "true" ]; then
        rm -f $MEDIA_DIR/temp/all_jf.mp4
        rm -f $MEDIA_DIR/temp/pikpak_jf.mp4
    fi
}

# emby
if [ "${EMBY_ENABLED:=false}" = "true" ]; then
    download_emby_config
    download_emby_media

    if [ "${AUTO_UPDATE_EMBY_CONFIG_ENABLED:=false}" = "true" ]; then
        echo "启动定时更新Emby配置任务..."
        # 随机生成一个时间，避免给服务器造成压力
        random_min=$(shuf -i 0-59 -n 1)
        random_hour=$(shuf -i 1-6 -n 1)
        crontabs="${crontabs}\n${random_min} ${random_hour} */${AUTO_UPDATE_EMBY_INTERVAL:=7} * * /emby.sh update"
    fi

    if [ "${AUTO_UPDATE_EMBY_METADATA_ENABLED:=false}" = "true" ]; then
        echo "启动定时更新Emby媒体数据任务..."
        # 随机生成一个时间，避免给服务器造成压力
        random_min=$(shuf -i 0-59 -n 1)
        random_hour=$(shuf -i 1-6 -n 1)
        crontabs="${crontabs}\n${random_min} ${random_hour} * * * python3 /solid.py --media ${MEDIA_DIR}/xiaoya"
    fi
fi

# jellyfin
if [ "${JELLYFIN_ENABLED:=false}" = "true" ]; then
    download_jellyfin_config
    download_jellyfin_media
fi

# 添加定时任务
if [ -n "${crontabs}" ]; then
    echo -e "$crontabs" | crontab -
fi

echo "Complete." 

cron -f
