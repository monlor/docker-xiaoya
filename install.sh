#!/bin/bash

set -e

sedsh() {
  if [[ "$(uname -o)" = "Darwin" ]]; then
    # macOS
    sed -i '' "$@"
  else
    # Linux
    sed -i "$@"
  fi
}

# 格式https://xxx.com/
GH_PROXY="${GH_PROXY:=}"
# 格式xxx.com
IMAGE_PROXY="${IMAGE_PROXY:=}"

# 欢迎信息
echo "欢迎使用xiaoya服务部署脚本"
echo "项目地址：https://github.com/monlor/docker-xiaoya"
echo "作者：monlor (https://link.monlor.com)"
echo

# 检查docker服务是否存在，不存在则询问用户是否安装，不安装退出脚本
if ! command -v docker &> /dev/null; then
  if [ "$(uname -o)" = "Darwin" ]; then
    echo "Docker 未安装，请安装docker后再运行脚本，推荐OrbStack：https://orbstack.dev/"
    exit 1
  fi
  echo "Docker 未安装，是否安装？(y/n)"
  read install
  if [ "$install" = "y" ]; then
    echo "安装docker..."
    curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
    systemctl enable docker
    systemctl start docker
  else 
    echo "退出安装"
    exit 1
  fi
fi

DOCKER_COMPOSE="docker compose"

# 检查是否安装了compose插件,docker compose 命令
if ! docker compose &> /dev/null && ! which docker-compose &> /dev/null; then
  read -p "docker compose 未安装，是否安装？(y/n)" install
  if [ "$install" = "y" ]; then
    echo "安装docker compose..."
    # 判断系统是x86还是arm，arm有很多种类，都要判断
    if [ "$(uname -m)" = "aarch64" ]; then
      file=docker-compose-linux-aarch64
    elif [ "$(uname -m)" = "x86_64" ]; then
      file=docker-compose-linux-x86_64
    else
      echo "不支持的系统架构$(uname -m), 请自行安装docker compose(https://docs.docker.com/compose/install/linux/#install-using-the-repository)"
      exit 1
    fi
    curl -SL "${GH_PROXY}https://github.com/docker/compose/releases/download/v2.27.1/$file" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
  else
    echo "退出安装"
    exit 1
  fi
fi

if ! docker compose &> /dev/null; then
  DOCKER_COMPOSE="docker-compose"
fi

# 让用户输入服务部署目录，默认/opt/xiaoya
read -p "请输入服务部署目录（默认/opt/xiaoya）：" install_path
install_path=${install_path:=/opt/xiaoya}

# 检查服务是否已经运行
echo "检查服务是否已经存在..."
if [ -f "$install_path/docker-compose.yml" ]; then
  # 询问用户是否要更新服务
  read -p "检查到服务已存在，是否更新服务？(y/n)" update
  if [ "${update}" != "y" ]; then
    echo "退出安装"
    exit 1
  fi
fi

# 如果是更新服务，则从原有的compose配置中获取token等信息
if [ "${update}" = "y" ]; then
  token=$(cat $install_path/env 2> /dev/null | grep ALIYUN_TOKEN | awk -F '=' '{print $2}')
  open_token=$(cat $install_path/env 2> /dev/null | grep ALIYUN_OPEN_TOKEN | awk -F '=' '{print $2}')
  folder_id=$(cat $install_path/env 2> /dev/null | grep ALIYUN_FOLDER_ID | awk -F '=' '{print $2}')
fi

# 让用户输入阿里云盘TOKEN，token获取方式教程：https://alist.nn.ci/zh/guide/drivers/aliyundrive.html 
echo
echo "阿里云盘token获取方式教程：https://alist.nn.ci/zh/guide/drivers/aliyundrive.html"
read -p "请输入阿里云盘TOKEN(默认为$token)：" res
token=${res:=$token}
if [ ${#token} -ne 32 ]; then
  echo "长度不对,阿里云盘 Token是32位"
  exit 1
fi

# 让用户输入阿里云盘OpenTOKEN，token获取方式教程：https://alist.nn.ci/zh/guide/drivers/aliyundrive_open.html
echo
echo "阿里云盘Open token获取方式教程：https://alist.nn.ci/zh/guide/drivers/aliyundrive_open.html"
read -p "请输入阿里云盘Open TOKEN(默认为$open_token)：" res
open_token=${res:=$open_token}
if [ ${#open_token} -le 334 ]; then
  echo "长度不对,阿里云盘 Open Token是335位"
  exit 1
fi

# 让用户输入阿里云盘转存目录folder_id，folder_id获取方式教程：https://www.aliyundrive.com/s/rP9gP3h9asE
echo
echo "转存以下文件到你的网盘，进入文件夹，获取地址栏末尾的文件夹ID：https://www.aliyundrive.com/s/rP9gP3h9asE"
read -p "请输入阿里云盘转存目录folder_id(默认为$folder_id)：" res
folder_id=${res:=$folder_id}
if [ ${#folder_id} -ne 40 ]; then
  echo "长度不对,阿里云盘 folder id是40位"
  exit 1
fi

# 选择部署服务类型，alist + emby (默认), alist, alist + jellyfin, alist + emby + jellyfin
echo
echo "部署类型："
echo "1. alist + emby (默认)"
echo "2. alist"
echo "3. alist + jellyfin"
echo "4. alist + emby + jellyfin"
read -p "请选择部署服务类型：" service_type
case $service_type in
  1)
    service_type=""
    ;;
  2)
    service_type="-alist"
    ;;
  3)
    service_type="-jellyfin"
    ;;
  4)
    service_type="-all"
    ;;
  *)
    service_type=""
    ;;
esac


# 检查目录是否存在，不存在则创建
if [ ! -d "$install_path" ]; then
  mkdir -p $install_path
fi

cd $install_path

echo "开始生成配置文件docker-compose${service_type}.yml..."
curl -#Lo $install_path/docker-compose.yml "${GH_PROXY}https://raw.githubusercontent.com/monlor/docker-xiaoya/main/docker-compose${service_type}.yml"
if [ ! -f $install_path/env ]; then
  curl -#Lo $install_path/env "${GH_PROXY}https://raw.githubusercontent.com/monlor/docker-xiaoya/main/env"
fi
sedsh "s#ALIYUN_TOKEN=.*#ALIYUN_TOKEN=$token#g" env
sedsh "s#ALIYUN_OPEN_TOKEN=.*#ALIYUN_OPEN_TOKEN=$open_token#g" env
sedsh "s#ALIYUN_FOLDER_ID=.*#ALIYUN_FOLDER_ID=$folder_id#g" env

if [ -n "$IMAGE_PROXY" ]; then
  sedsh -E "s#image: [^/]+#image: ${IMAGE_PROXY}#g" docker-compose.yml
fi

echo "开始部署服务..."
$DOCKER_COMPOSE -f docker-compose.yml up --remove-orphans --pull=always -d

echo "服务开始部署，如果部署emby/jellyfin，下载并解压60G元数据需要一段时间，请耐心等待..."

echo 
echo "> 服务管理（请牢记以下命令）"
# 提示用户compose如何查看日志，启动，重启，停止服务
echo "查看日志：$DOCKER_COMPOSE -f $install_path/docker-compose.yml logs -f"
# 更新服务
echo "启动服务：$DOCKER_COMPOSE -f $install_path/docker-compose.yml start"
echo "重启服务：$DOCKER_COMPOSE -f $install_path/docker-compose.yml restart"
echo "停止服务：$DOCKER_COMPOSE -f $install_path/docker-compose.yml down"
echo "高级用户自定义配置：$install_path/env"

# 获取当前服务器ip
ip=$(curl -s ip.sb 2> /dev/null)
# 内网ip
local_ip=$(ifconfig | grep 'inet ' | grep -v '127.0.0.1' | awk '{ print $2 }' | head -1)

echo 
echo "> 等待服务部署完成后访问地址如下"
echo "alist地址: http://$local_ip:5678, http://$ip:5678"
echo "webdav地址: http://$local_ip:5678/dav, http://$ip:5678/dav, 默认用户密码: guest/guest_Api789"
echo "tvbox地址: http://$local_ip:5678/tvbox/my_ext.json, http://$ip:5678/tvbox/my_ext.json"
echo "emby地址: http://$local_ip:6908, http://$ip:6908, 默认用户密码: xiaoya/1234"
echo "jellyfin地址: http://$local_ip:8096, http://$ip:8096"
