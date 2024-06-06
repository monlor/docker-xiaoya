#!/bin/sh

echo "等待alist启动完成..."
while ! wget -q -T 1 -O /dev/null "${ALIST_ADDR:=http://alist:5678}" > /dev/null 2>&1; do
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
/emby.sh start
sleep 2

echo "启动进程守护..."
/emby.sh daemon &

exec shell2http -port 8080 /stop "/emby.sh stop" /start "/emby.sh start"
