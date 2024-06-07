#!/bin/sh

ALIST_ADDR=${ALIST_ADDR:-http://alist:5678}
UPDATE_ALIST_ADDR_INTERVAL=${UPDATE_ALIST_ADDR_INTERVAL:-60}

# 解析ALIST_ADDR里面的域名或ip
ALIST_DOMAIN=$(echo "${ALIST_ADDR}" | sed -e 's#http://##' -e 's#https://##' -e 's#:[0-9]*##' -e 's#/$##')

add_hosts() {
  # 容器里不能使用sed -i，所以使用临时文件
  sed -e "/xiaoya.host/d" /etc/hosts > /tmp/hosts
  printf "%s\txiaoya.host\n" "$1" >> /tmp/hosts
  cat /tmp/hosts > /etc/hosts
}

if echo "${ALIST_DOMAIN}" | grep -E -q '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$'; then
  IP="${ALIST_DOMAIN}"
  echo "Alist IP address: $IP"
  add_hosts "$IP"
  exit 0
fi

while true; do
  IP=$(ping -c 1 "${ALIST_DOMAIN}" | grep -Eo '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | head -n 1)
  if [ -n "$IP" ]; then
    echo "Alist IP address: $IP"
    add_hosts "$IP"
  else
    echo "Failed to resolve Alist domain ${ALIST_DOMAIN}..."
  fi

  echo "Waiting for $UPDATE_ALIST_ADDR_INTERVAL seconds..."
  sleep "${UPDATE_ALIST_ADDR_INTERVAL}"
done
