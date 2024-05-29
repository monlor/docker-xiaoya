#!/bin/sh

set -e

echo "等待alist启动完成..."
while ! curl -s -f -m 1 "${ALIST_ADDR:=http://alist:80}" > /dev/null; do
    sleep 2
done

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


if [ "${EMBY_ENABLED:=false}" = "true" ]; then
    if [ -f /media/config/emby_meta_finished ]; then
        echo "Emby metadata has been downloaded. Delete the file /media/config/emby_meta_finished to re-download."
    else
        disk_check 100
        cd "${MEDIA_DIR}/temp"
        /update_all.sh "${ALIST_ADDR}"
        if [ $? -eq 0 ]; then
            touch /media/config/emby_meta_finished
        fi
    fi
fi

if [ "${JELLYFIN_ENABLED:=false}" = "true" ]; then
    if [ -f /media/config/jellyfin_meta_finished ]; then
        echo "Jellyfin metadata has been downloaded. Delete the file /media/config/jellyfin_meta_finished to re-download."
    else

        disk_check 100

        echo "Downloading Jellyfin metadata..."

        cd /media/temp

        if [ ! -f "${MEDIA_DIR}/temp/config_jf.mp4" ]; then
            echo "Downloading config_jf.mp4..."
            aria2c -o config_jf.mp4 --allow-overwrite=true --auto-file-renaming=false --enable-color=false -c -x6 "${ALIST_ADDR}/d/元数据/Jellyfin/config_jf.mp4"
        fi
        if [ ! -f "${MEDIA_DIR}/temp/all_jf.mp4" ]; then
            echo "Downloading metadata all_jf.mp4..."
            aria2c -o all_jf.mp4 --allow-overwrite=true --auto-file-renaming=false --enable-color=false -c -x6 "${ALIST_ADDR}/d/元数据/Jellyfin/all_jf.mp4"
        fi
        if [ ! -f "${MEDIA_DIR}/temp/PikPak_jf.mp4" ]; then
            echo "Downloading PikPak_jf.mp4..."
            aria2c -o PikPak_jf.mp4 --allow-overwrite=true --auto-file-renaming=false --enable-color=false -c -x6 "${ALIST_ADDR}/d/元数据/Jellyfin/PikPak_jf.mp4"
        fi
        
        echo "Extracting Jellyfin metadata..."

        cd /media
        7z x -aoa -mmt=16 temp/config_jf.mp4

        cd /media/xiaoya
        7z x -aoa -mmt=16 /media/temp/all_jf.mp4

        cd /media/xiaoya
        7z x -aoa -mmt=16 /media/temp/PikPak_jf.mp4

        touch /media/config/jellyfin_meta_finished
    
    fi
fi

echo "Complete." 

touch /media/config/meta_finished

tail -f /dev/null