#!/bin/sh

echo "等待alist启动完成..."
while ! wget -q -T 1 -O /dev/null "${ALIST_ADDR:=http://alist:5678}" &> /dev/null; do
    sleep 2
done

echo "等待元数据下载完成..."
while test ! -f /config/emby_meta_finished; do
    sleep 2
done

cat > /etc/nsswitch.conf <<-EOF
hosts:  files dns
networks:   files
EOF

echo "开始自动更新alist地址..."
/update_alist_addr.sh &> /dev/null &

exec /init