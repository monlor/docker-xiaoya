#!/bin/bash

set -eu

sedsh() {
  if [[ "$(uname -o)" = "Darwin" ]]; then
    # macOS
    sed -i '' "$@"
  else
    # Linux
    sed -i "$@"
  fi
}

# 解除read输入长度限制
if [[ "$(uname -o)" = "Darwin" ]]; then
  stty -icanon
fi

# 格式https://xxx.com/
GH_PROXY="${GH_PROXY:=}"
# 格式xxx.com
IMAGE_PROXY="${IMAGE_PROXY:=}"

# 服务镜像
IMAGE_TAG="${VERSION:-latest}"
# 服务下载地址
DOWNLOAD_URL="${GH_PROXY}https://raw.githubusercontent.com/monlor/docker-xiaoya/${VERSION:-main}"

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
  read -rp "Docker 未安装，是否安装？(y/n): " install
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
  read -rp "Docker Compose 未安装，是否安装？(y/n): " install
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
read -rp "请输入服务部署目录（默认/opt/xiaoya）: " install_path
install_path=${install_path:=/opt/xiaoya}

# 检查服务是否已经运行
update=0
if [ -f "$install_path/docker-compose.yml" ]; then
  # 询问用户是否要更新服务
  cat <<-EOF

更新方式：
1. 全部更新，会覆盖更新docker-compose.yml和env配置
2. 部分更新，仅覆盖更新docker-compose.yml
3. 退出脚本，不更新
EOF
  read -rp "请选择更新方式（默认为1）: " update
  update=${update:-1}
  case $update in
    1|2)
      # 备份
      cp -rf "$install_path/env" "$install_path/env.bak"
      cp -rf "$install_path/docker-compose.yml" "$install_path/docker-compose.yml.bak"
      ;;
    *)
      echo "退出安装"
      exit 1
      ;;
  esac
  
fi

DOCKER_HOME="$(docker info | grep "Docker Root Dir" | awk -F ':' '{print$2}')"

# 选择数据保存位置
data_location=1
if [ -d "$install_path/data" ]; then
  data_location=2
fi
cat <<-EOF

数据保存位置：
1. Docker卷（数据保存在: ${DOCKER_HOME}/volumes）
2. 服务部署目录（数据保存在: ${install_path}）
EOF
read -rp "请选择数据保存位置（默认为${data_location}）: " res
data_location=${res:-${data_location}}

token=""
open_token=""
folder_id=""
quark_cookie=""
pan115_cookie=""
aliyun_to_115="false"
pan115_folder_id=""

# 如果是更新服务，则从原有的compose配置中获取token等信息
if [ "${update}" != "0" ]; then
  token=$(grep ALIYUN_TOKEN "$install_path/env" 2> /dev/null | cut -d '=' -f2-)
  open_token=$(grep ALIYUN_OPEN_TOKEN "$install_path/env" 2> /dev/null | cut -d '=' -f2-)
  folder_id=$(grep ALIYUN_FOLDER_ID "$install_path/env" 2> /dev/null | cut -d '=' -f2-)
  quark_cookie=$(grep QUARK_COOKIE "$install_path/env" 2> /dev/null | cut -d '=' -f2-)
  pan115_cookie=$(grep PAN115_COOKIE "$install_path/env" 2> /dev/null | cut -d '=' -f2-)
  aliyun_to_115=$(grep ALIYUN_TO_115 "$install_path/env" 2> /dev/null | cut -d '=' -f2-)
  pan115_folder_id=$(grep PAN115_FOLDER_ID "$install_path/env" 2> /dev/null | cut -d '=' -f2-)
fi

# 让用户输入阿里云盘TOKEN，token获取方式教程：https://alist.nn.ci/zh/guide/drivers/aliyundrive.html 
echo
echo "阿里云盘token获取方式教程：https://alist.nn.ci/zh/guide/drivers/aliyundrive.html"
read -rp "请输入阿里云盘TOKEN(默认为$token): " res
token=${res:=$token}
if [ ${#token} -ne 32 ]; then
  echo "长度不对,阿里云盘 Token是32位"
  exit 1
fi

# 让用户输入阿里云盘OpenTOKEN，token获取方式教程：https://alist.nn.ci/zh/guide/drivers/aliyundrive_open.html
echo
echo "阿里云盘Open token获取方式教程：https://alist.nn.ci/zh/guide/drivers/aliyundrive_open.html"
read -rp "请输入阿里云盘Open TOKEN(默认为$open_token): " res
open_token=${res:=$open_token}
if [ ${#open_token} -le 334 ]; then
  echo "长度不对,阿里云盘 Open Token是335位"
  exit 1
fi

# 让用户输入阿里云盘转存目录folder_id，folder_id获取方式教程：https://www.aliyundrive.com/s/rP9gP3h9asE
echo
echo "进入阿里云盘网页版，资源盘里面创建一个文件夹，点击文件夹，复制浏览器阿里云盘地址末尾的文件夹ID（最后一个斜杠/后面的一串字符串）"
read -rp "请输入阿里云盘缓存目录ID(默认为$folder_id): " res
folder_id=${res:=$folder_id}
if [ ${#folder_id} -ne 40 ]; then
  echo "长度不对,阿里云盘 folder id是40位"
  exit 1
fi

echo 
echo "登陆夸克网盘，浏览器F12，点击network，随便点一个请求，找到里面的Cookie值"
read -rp "请输入夸克网盘Cookie值(默认为$quark_cookie): " res
quark_cookie=${res:=$quark_cookie}

echo 
echo "登陆115网盘，浏览器F12，点击network，随便点一个请求，找到里面的Cookie值"
read -rp "请输入115网盘Cookie值(默认为$pan115_cookie): " res
pan115_cookie=${res:=$pan115_cookie}

if [ -n "${pan115_cookie}" ]; then
  read -rp "是否开启将阿里云盘转存到115播放？[y/n]: " res
  if [ "${res}" = "y" ]; then
    aliyun_to_115="true"
    read -rp "请输入115网盘文件夹ID(默认为$pan115_folder_id): " res
    pan115_folder_id=${res:=$pan115_folder_id}
    if [ -n "${pan115_folder_id}" ] && [ ${#pan115_folder_id} -ne 19 ] && [ "${pan115_folder_id}" != "0" ]; then
      echo "长度不对,115网盘 folder id是19位"
      exit 1
    fi
  else
    aliyun_to_115="false"
  fi
fi

# 选择部署服务类型，alist + emby (默认), alist
echo
echo "部署类型："
echo "1. alist + emby (默认)"
echo "2. alist"
read -rp "请选择部署服务类型: " service_type
case $service_type in
  1)
    service_type=""
    ;;
  2)
    service_type="-alist"
    ;;
  *)
    service_type=""
    ;;
esac


# 检查目录是否存在，不存在则创建
if [ ! -d "$install_path" ]; then
  mkdir -p "$install_path"
fi

cd "$install_path"

echo "开始生成配置文件docker-compose${service_type}.yml..."
curl -#Lo "$install_path/docker-compose.yml" "${DOWNLOAD_URL}/docker-compose${service_type}.yml"
if [ "${update}" != "2" ]; then
  curl -#Lo "$install_path/env" "${DOWNLOAD_URL}/env"
fi
sedsh "s#ALIYUN_TOKEN=.*#ALIYUN_TOKEN=$token#g" env
sedsh "s#ALIYUN_OPEN_TOKEN=.*#ALIYUN_OPEN_TOKEN=$open_token#g" env
sedsh "s#ALIYUN_FOLDER_ID=.*#ALIYUN_FOLDER_ID=$folder_id#g" env
sedsh "s#QUARK_COOKIE=.*#QUARK_COOKIE=$quark_cookie#g" env
sedsh "s#PAN115_COOKIE=.*#PAN115_COOKIE=$pan115_cookie#g" env
sedsh "s#ALIYUN_TO_115=.*#ALIYUN_TO_115=$aliyun_to_115#g" env
sedsh "s#PAN115_FOLDER_ID=.*#PAN115_FOLDER_ID=$pan115_folder_id#g" env

if [ -n "$IMAGE_PROXY" ]; then
  sedsh -E "s#image: [^/]+#image: ${IMAGE_PROXY}#g" docker-compose.yml
fi

# 修改镜像版本
sedsh "s#:latest#:$IMAGE_TAG#g" docker-compose.yml

# 修改数据保存位置
if [ "$data_location" = "2" ]; then
  sed -n '/^volumes/,$p' ./docker-compose.yml | sed -e 's/://g' | grep -v volumes | while read -r volume; do
    if [ -z "${volume}" ]; then
      continue
    fi
    if [ ! -d "$install_path/data/$volume" ]; then
      mkdir -p "$install_path/data/$volume"
    fi
    sedsh "s#- $volume:#- $install_path/data/$volume:#g" docker-compose.yml
  done
  sedsh "/^volumes/,\$d" docker-compose.yml
fi

echo "开始部署服务..."
$DOCKER_COMPOSE -f docker-compose.yml up --remove-orphans --pull=always -d

echo "服务开始部署，如果部署emby，下载并解压60G元数据需要一段时间，请耐心等待..."
echo "脚本执行完成不代表服务启动完成，请执行下面的命令查看日志来检查部署情况."

echo 
echo "> 服务管理（请牢记以下命令）"
# 提示用户compose如何查看日志，启动，重启，停止服务
echo "查看日志：$install_path/manage.sh logs"
# 更新服务
echo "启动服务：$install_path/manage.sh start"
echo "停止服务：$install_path/manage.sh stop"
echo "重启服务：$install_path/manage.sh restart"
echo "加载配置：$install_path/manage.sh reload"
echo "更新服务：$install_path/manage.sh update"
echo "高级用户自定义配置：$install_path/env"
echo "修改env或者compose配置后，需要执行上面的加载配置reload命令生效！"

# 获取当前服务器ip
ip=$(curl -s ip.3322.net 2> /dev/null)
# 内网ip
local_ip=""
if [[ "$(uname -o)" = "Darwin" ]]; then
  interface="$(route -n get default | grep interface | awk -F ':' '{print$2}' | awk '{$1=$1};1')"
  local_ip="$(ifconfig "${interface}" | grep 'inet ' | awk '{print$2}')"
else
  interface="$(ip route | grep default | awk '{print$5}')"
  local_ip="$(ip -o -4 addr show "${interface}" | awk '{print $4}' | cut -d/ -f1)"
fi

echo 
echo "> 服务正在部署，请查看日志等待部署成功后，尝试访问下面的地址"
echo "alist: http://$local_ip:5678, http://$ip:5678"
echo "webdav: http://$local_ip:5678/dav, http://$ip:5678/dav, 默认用户密码: guest/guest_Api789"
echo "tvbox: http://$local_ip:5678/tvbox/my_ext.json, http://$ip:5678/tvbox/my_ext.json"
echo "emby: http://$local_ip:2345, http://$ip:2345, 默认用户密码: xiaoya/1234"

echo
echo "服务正在后台部署，执行这个命令查看日志：$install_path/manage.sh logs"
echo "部署alist需要10分钟，emby需要1-24小时，请耐心等待..."
# 添加管理脚本，启动，停止，查看日志
cat > "$install_path/manage.sh" <<-EOF
#!/bin/bash

set -e

case \$1 in
  start)
    $DOCKER_COMPOSE -f "$install_path/docker-compose.yml" start
    ;;
  stop)
    $DOCKER_COMPOSE -f "$install_path/docker-compose.yml" stop
    ;;
  restart)
    $DOCKER_COMPOSE -f "$install_path/docker-compose.yml" restart
    ;;
  reload)
    $DOCKER_COMPOSE -f "$install_path/docker-compose.yml" up --remove-orphans -d
    ;;
  logs)
    $DOCKER_COMPOSE -f "$install_path/docker-compose.yml" logs -f
    ;;
  update)
    $DOCKER_COMPOSE -f "$install_path/docker-compose.yml" up --remove-orphans --pull=always -d 
    ;;
  *)
    echo "Usage: \$0 {start|stop|restart|reload|logs|update}"
    exit 1
    ;;
esac
EOF

chmod +x "$install_path/manage.sh"
