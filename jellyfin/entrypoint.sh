#!/bin/sh

echo "等待alist启动完成..."
while ! curl -s -f -m 1 http://${ALIST_DOMAIN}:${ALIST_PORT:=5678} &> /dev/null; do
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

if echo "${ALIST_DOMAIN}" | grep -E -q '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$'; then
    IP="${ALIST_DOMAIN}"
    echo "Alist IP address: $IP"
else
    # 使用 nslookup 解析 Alist 域名
    IP=$(nslookup "${ALIST_DOMAIN:=alist}" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -n 1)

    # 检查 IP 地址是否解析成功
    if [ -z "$IP" ]; then
        echo "Error: Failed to resolve IP address for ${ALIST_DOMAIN}"
        exit 1
    else
        echo "Alist IP address: $IP"
    fi
fi

# 容器里不能使用sed -i，所以使用临时文件
sed -e "/xiaoya.host/d" /etc/hosts > /tmp/hosts
echo -e "$IP\txiaoya.host" >> /tmp/hosts
cat /tmp/hosts > /etc/hosts

/jellyfin/jellyfin --datadir /config --cachedir /cache --ffmpeg /usr/lib/jellyfin-ffmpeg/ffmpeg