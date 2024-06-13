#!/bin/sh

ALIST_ADDR=${ALIST_ADDR:-http://alist:5678}

echo "检查alist连通性..."
while ! curl -s --fail "${ALIST_ADDR}/api/public/settings" | grep -q 200; do
    sleep 2
done

echo "等待配置数据下载完成..."
while test ! -f /config/jellyfin_meta_finished; do
    sleep 2
done

echo "等待媒体数据下载完成..."
while test ! -f /media/jellyfin_media_finished; do
    sleep 2
done

cat > /etc/nsswitch.conf <<-EOF
hosts:  files dns
networks:   files
EOF

echo "开始自动更新alist地址..."
/update_alist_addr.sh > /dev/null 2>&1 &

/jellyfin/jellyfin --datadir /config --cachedir /cache --ffmpeg /usr/lib/jellyfin-ffmpeg/ffmpeg