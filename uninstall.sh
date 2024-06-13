#!/bin/bash

set -eu

read -rp "请输入服务部署目录（默认/opt/xiaoya）: " install_path
install_path=${install_path:=/opt/xiaoya}

if [ ! -d "$install_path" ]; then
  echo "目录不存在，退出卸载"
  exit 1
fi

DOCKER_COMPOSE="docker compose"

if ! docker compose &> /dev/null; then
  DOCKER_COMPOSE="docker-compose"
fi

docker_params=""
read -rp "是否删除数据卷？(y/n): " delete_volume
if [ "$delete_volume" = "y" ]; then
  docker_params="--volumes"
fi

echo "停止服务..."
$DOCKER_COMPOSE -f "$install_path/docker-compose.yml" down $docker_params

if [ "$delete_volume" = "y" ]; then
  rm -rf "${install_path:?}"/*
else
  find "${install_path:?}" -type f -not -path "${install_path}/data/*" -delete
fi