#!/bin/sh

# 欢迎信息
echo "欢迎使用xiaoya服务部署脚本"
echo "项目地址：https://github.com/monlor/docker-xiaoya"
echo "作者：monlor (https://link.monlor.com)"
echo

# 检查docker服务是否存在，不存在则询问用户是否安装，不安装退出脚本
if ! command -v docker &> /dev/null; then
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

# 让用户输入服务部署目录，默认/opt/xiaoya
echo "请输入服务部署目录，默认/opt/xiaoya"
read -p "请输入服务部署目录：" install_path
install_path=${install_path:=/opt/xiaoya}

# 让用户输入阿里云盘TOKEN，token获取方式教程：https://alist.nn.ci/zh/guide/drivers/aliyundrive.html 
echo "阿里云盘token获取方式教程：https://alist.nn.ci/zh/guide/drivers/aliyundrive.html"
read -p "请输入阿里云盘TOKEN：" token
if [ ${#token} -ne 32 ]; then
  echo "长度不对,阿里云盘 Token是32位"
  exit 1
fi

# 让用户输入阿里云盘OpenTOKEN，token获取方式教程：https://alist.nn.ci/zh/guide/drivers/aliyundrive_open.html
echo "阿里云盘Open token获取方式教程：https://alist.nn.ci/zh/guide/drivers/aliyundrive_open.html"
read -p "请输入阿里云盘Open TOKEN：" open_token
if [ ${#open_token} -le 334 ]; then
  echo "长度不对,阿里云盘 Open Token是335位"
  exit 1
fi

# 让用户输入阿里云盘转存目录folder_id，folder_id获取方式教程：https://www.aliyundrive.com/s/rP9gP3h9asE
echo "转存以下文件到你的网盘，进入文件夹，获取地址栏末尾的文件夹ID：https://www.aliyundrive.com/s/rP9gP3h9asE"
read -p "请输入阿里云盘转存目录folder_id：" folder_id
if [ ${#folder_id} -ne 40 ]; then
  echo "长度不对,阿里云盘 folder id是40位"
  exit 1
fi

# 选择部署服务类型，alist + emby (默认), alist, alist + jellyfin, alist + emby + jellyfin
echo "请选择部署服务类型："
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

echo "开始生成配置文件..."
curl -LO https://raw.githubusercontent.com/monlor/docker-xiaoya/main/docker-compose${service_type}.yml
sed -i "s#ALIYUN_TOKEN=.*#ALIYUN_TOKEN=$token#g" docker-compose.yml
sed -i "s#ALIYUN_OPEN_TOKEN=.*#ALIYUN_OPEN_TOKEN=$open_token#g" docker-compose.yml
sed -i "s#ALIYUN_FOLDER_ID=.*#ALIYUN_FOLDER_ID=$folder_id#g" docker-compose.yml

echo "开始部署服务..."
docker compose -f docker-compose.yml up --remove-orphans -d

echo "服务部署完成，下载并解压60G元数据需要一段时间，请耐心等待..."

echo 
echo "> 服务管理"
# 提示用户compose如何查看日志，启动，重启，停止服务
echo "查看日志：docker compose -f $install_path/docker-compose.yml logs -f"
echo "启动服务：docker compose -f $install_path/docker-compose.yml start"
echo "重启服务：docker compose -f $install_path/docker-compose.yml restart"
echo "停止服务：docker compose -f $install_path/docker-compose.yml down"

# 获取当前服务器ip
ip=$(curl -s ip.sb 2> /dev/null)
# 内网ip
local_ip=$(hostname -I | awk '{print $1}')

echo 
echo "> 等待服务部署完成后访问地址如下"
echo "alist地址: http://$local_ip:5678, http://$ip:5678"
echo "webdav地址: http://$local_ip:5678/dav, http://$ip:5678/dav, 默认用户密码: guest/guest_Api789"
echo "emby地址: http://$local_ip:6908, http://$ip:6908, 默认用户密码: xiaoya/1234"
echo "jellyfin地址: http://$local_ip:8096, http://$ip:8096"
