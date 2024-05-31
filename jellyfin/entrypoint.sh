#!/bin/sh

echo "等待alist启动完成..."
while ! curl -s -f -m 1 "${ALIST_ADDR:=http://alist:5678}" &> /dev/null; do
    sleep 2
done

echo "等待元数据下载完成..."
while test ! -f /config/jellyfin_meta_finished; do
    sleep 2
done

cat > /etc/nsswitch.conf <<-EOF
hosts:  files dns
networks:   files
EOF

echo "开始自动更新alist地址..."
/update_alist_addr.sh &> /dev/null &

/jellyfin/jellyfin --datadir /config --cachedir /cache --ffmpeg /usr/lib/jellyfin-ffmpeg/ffmpeg