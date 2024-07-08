#!/bin/sh

ALIST_ADDR=${ALIST_ADDR:-http://alist:5678}

echo "检查alist连通性..."
while ! wget -Y off -q -T 1 -O - "${ALIST_ADDR}/api/public/settings" 2> /dev/null | grep -q 200; do
    sleep 2
done

echo "等待配置数据下载完成..."
while test ! -f /config/emby_meta_finished; do
    sleep 2
done

echo "等待媒体数据下载完成..."
while test ! -f /media/emby_media_finished; do
    sleep 2
done

cat > /etc/nsswitch.conf <<-EOF
hosts:  files dns
networks:   files
EOF

echo "开始自动更新alist地址..."
/update_alist_addr.sh > /dev/null 2>&1 &

echo "启动emby服务..."
/service.sh start
sleep 2

echo "启动进程守护..."
/service.sh daemon &

exec shell2http -port 8080 /stop "/service.sh stop" /start "/service.sh start"
