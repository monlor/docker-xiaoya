#!/bin/bash

set -e

echo "等待alist启动完成..."
while ! curl -s -f -m 1 "${ALIST_ADDR:=http://alist:5678}" > /dev/null; do
    sleep 2
done

echo "alist启动完成，可能需要一段时间加载数据，等待5分钟后开始下载元数据..."
sleep "${WAIT_ALIT_TIME:=300}"

MEDIA_DIR="/media"

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
    # 磁盘检测
    free_size=$(df -P "${MEDIA_DIR}" | tail -n1 | awk '{print $4}')
    free_size=$((free_size))
    free_size_G=$((free_size / 1024 / 1024))
    if [ $free_size_G -lt "${1}" ]; then
        echo "Error: Insufficient disk space, at least ${1}G of free space is required."
        exit 1
    fi
}  

download_meta() {
    file=$1
    path=$2
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

    # 重试3次下载，包含.aria2则重试
    for i in {1..5}; do
        echo "Downloading ${file}, try ${i}..."
        aria2c -o "${file}" --allow-overwrite=true --auto-file-renaming=false --enable-color=false -c -x6 "${ALIST_ADDR}/d/元数据/${path}${file}"
        if [ ! -f "${file}.aria2" ]; then
            break
        fi
    done
    # 如果还存在aria2，或者下载的文件小于10M，则删除
    if [ -f "${file}.aria2" ] || [ "$(stat -c %s "${file}")" -lt 10000000 ]; then
        echo "Download ${file} failed."
        rm -rf "${file}"
        rm -rf "${file}.aria2"
        return 1
    fi
}

if [ "${EMBY_ENABLED:=false}" = "true" ]; then
    if [ -f ${MEDIA_DIR}/config/emby_meta_finished ]; then
        echo "Emby metadata has been downloaded. Delete the file ${MEDIA_DIR}/config/emby_meta_finished to re-download."
    else
        disk_check 140
        cd "${MEDIA_DIR}/temp"

        download_meta config.mp4
        download_meta all.mp4
        download_meta pikpak.mp4

        echo "Extracting Emby metadata..."

        cd ${MEDIA_DIR}
        7z x -aoa -mmt=16 temp/config.mp4

        cd ${MEDIA_DIR}/xiaoya
        7z x -aoa -mmt=16 ${MEDIA_DIR}/temp/all.mp4

        cd ${MEDIA_DIR}/xiaoya
        7z x -aoa -mmt=16 ${MEDIA_DIR}/temp/pikpak.mp4

        chmod -R 777 ${MEDIA_DIR}/xiaoya

        touch ${MEDIA_DIR}/config/emby_meta_finished
    fi
fi

if [ "${JELLYFIN_ENABLED:=false}" = "true" ]; then
    if [ -f ${MEDIA_DIR}/config/jellyfin_meta_finished ]; then
        echo "Jellyfin metadata has been downloaded. Delete the file ${MEDIA_DIR}/config/jellyfin_meta_finished to re-download."
    else

        disk_check 140

        echo "Downloading Jellyfin metadata..."

        cd ${MEDIA_DIR}/temp

        download_meta config_jf.mp4 Jellyfin/
        download_meta all_jf.mp4 Jellyfin/
        download_meta PikPak_jf.mp4 Jellyfin/
        
        echo "Extracting Jellyfin metadata..."

        cd ${MEDIA_DIR}
        7z x -aoa -mmt=16 temp/config_jf.mp4

        cd ${MEDIA_DIR}/xiaoya
        7z x -aoa -mmt=16 ${MEDIA_DIR}/temp/all_jf.mp4

        cd ${MEDIA_DIR}/xiaoya
        7z x -aoa -mmt=16 ${MEDIA_DIR}/temp/PikPak_jf.mp4

        chmod -R 777 ${MEDIA_DIR}/xiaoya

        touch ${MEDIA_DIR}/config/jellyfin_meta_finished
    
    fi
fi

crontabs=""

if [ "${AUTO_UPDATE_EMBY_CONFIG_ENABLED:=false}" = "true" ] && [ "${EMBY_ENABLED}" = "true" ]; then
    echo "启动定时更新Emby配置任务..."
    # 随机生成一个时间，避免给服务器造成压力
    random_min=$(shuf -i 0-59 -n 1)
    random_hour=$(shuf -i 1-6 -n 1)
    crontabs="${random_min} ${random_hour} */${AUTO_UPDATE_EMBY_INTERVAL:=7} * * /emby.sh update"
fi

if [ "${AUTO_UPDATE_EMBY_METADATA_ENABLED:=false}" = "true" ] && [ "${EMBY_ENABLED}" = "true" ]; then
    echo "启动定时更新Emby元数据任务..."
    # 随机生成一个时间，避免给服务器造成压力
    random_min=$(shuf -i 0-59 -n 1)
    random_hour=$(shuf -i 1-6 -n 1)
    crontabs="${crontabs}\n${random_min} ${random_hour} * * * python3 /solid.py --media ${MEDIA_DIR}/xiaoya"
fi

if [ -n "${crontabs}" ]; then
    echo -e "$crontabs" | crontab -
fi

echo "Complete." 

touch ${MEDIA_DIR}/config/meta_finished

cron -f
