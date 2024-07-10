#!/bin/bash

EMBY_ADDR=${EMBY_ADDR:-http://emby:6908}
JELLYFIN_ADDR=${JELLYFIN_ADDR:-http://jellyfin:8096}
UPDATE_MEDIA_ADDR_INTERVAL=${UPDATE_MEDIA_ADDR_INTERVAL:-60}

# 如果是IP地址，直接写入文件，不需要更新
EMBY_DOMAIN=$(echo "${EMBY_ADDR}" | sed -e 's#http://##' -e 's#https://##' -e 's#:[0-9]*##' -e 's#/$##')
JEELYFIN_DOMAIN=$(echo "${JELLYFIN_ADDR}" | sed -e 's#http://##' -e 's#https://##' -e 's#:[0-9]*##' -e 's#/$##')
EMBY_END=0
JELLYFIN_END=0

if [[ "${EMBY_DOMAIN}" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
  echo "Emby IP address: ${EMBY_DOMAIN}"
  echo "${EMBY_ADDR}" > /data/emby_server.txt
  EMBY_END=1
fi

if [[ "${JEELYFIN_DOMAIN}" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
  echo "Jellyfin IP address: ${JEELYFIN_DOMAIN}"
  echo "${JELLYFIN_ADDR}" > /data/jellyfin_server.txt
  JELLYFIN_END=1
fi

if [ $EMBY_END -eq 1 ] && [ $JELLYFIN_END -eq 1 ]; then
  exit 0
fi

# 解析域名为 IP
get_addr() {
  ADDR=$1
  if [[ $ADDR =~ ^(https?)://([^:/]+)(:[0-9]+)?$ ]]; then
    PROTOCOL=${BASH_REMATCH[1]}
    DOMAIN_OR_IP=${BASH_REMATCH[2]}
    PORT=${BASH_REMATCH[3]}

    # 默认端口设置
    if [ -z "$PORT" ]; then
      if [ "$PROTOCOL" == "http" ]; then
        PORT=":80"
      elif [ "$PROTOCOL" == "https" ]; then
        PORT=":443"
      fi
    fi

    # 解析域名为 IP
    IP=$(ping -c 1 "$DOMAIN_OR_IP" | grep -o '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | head -n 1)
    if [ -z "$IP" ]; then
      return 1
    fi
    echo "$PROTOCOL://$IP$PORT"
    return 0
  else
    echo 
    return 1
  fi
}

echo "等待emby.js创建完成..."
while ! test -f /etc/nginx/http.d/emby.js; do
    sleep 2
done

echo "开始更新媒体服务地址..."
# 设置一个循环每1分钟检查一次emby的地址是否变化，如果变化就更新/data/emby_server.txt
while true; do
  nginx_reload=0
  if [ "${EMBY_END}" -eq 0 ]; then
    NEW_EMBY_ADDR=$(get_addr "${EMBY_ADDR}")
    if [ -n "$NEW_EMBY_ADDR" ]; then
      if [ "$NEW_EMBY_ADDR" != "$OLD_EMBY_ADDR" ]; then
        echo "$NEW_EMBY_ADDR" > /data/emby_server.txt
        # 更新nginx配置
        sed -i "s#set \$emby .*#set \$emby ${NEW_EMBY_ADDR};#" /etc/nginx/http.d/emby.conf
        sed -i "s#const embyHost .*#const embyHost = '${NEW_EMBY_ADDR}';#" /etc/nginx/http.d/emby.js
        nginx_reload=1
        OLD_EMBY_ADDR=$NEW_EMBY_ADDR
        echo "Updated emby address to $NEW_EMBY_ADDR"
      fi
    else
      echo "Error: Failed to resolve IP address for ${EMBY_ADDR}"
    fi
  fi

  if [ "${JELLYFIN_END}" -eq 0 ]; then
    NEW_JELLYFIN_ADDR=$(get_addr "${JELLYFIN_ADDR}")
    if [ -n "$NEW_JELLYFIN_ADDR" ]; then
      if [ "$NEW_JELLYFIN_ADDR" != "$OLD_JELLYFIN_ADDR" ]; then
        echo "$NEW_JELLYFIN_ADDR" > /data/jellyfin_server.txt
        # 更新nginx配置
        sed -i "s#set \$emby .*#set \$emby ${NEW_JELLYFIN_ADDR};#" /etc/nginx/http.d/jellyfin.conf
        sed -i "s#const embyHost .*#const embyHost = '${NEW_JELLYFIN_ADDR}';#" /etc/nginx/http.d/jellyfin.js
        nginx_reload=1
        OLD_JELLYFIN_ADDR=$NEW_JELLYFIN_ADDR
        echo "Updated jellyfin address to $NEW_JELLYFIN_ADDR"
      fi
    else
      echo "Error: Failed to resolve IP address for ${JELLYFIN_ADDR}"
    fi
  fi

  if [ "$nginx_reload" -eq 1 ]; then
    echo "Reloading nginx..."
    nginx -s reload
  fi

  echo "Waiting for $UPDATE_MEDIA_ADDR_INTERVAL seconds..."
  sleep "${UPDATE_MEDIA_ADDR_INTERVAL}"
done
