#!/bin/bash

set -eu

echo "开始生成配置文件..."

if [ ! -d "/data" ]; then
    mkdir /data
fi

# 设置端口
local_ip=$(ip a | grep inet | grep -v '127.0.0.1|inet6' | awk '{print $2}' | cut -d/ -f1)
echo "http://$local_ip:5678" > /data/docker_address.txt

# 生成配置，阿里云token
if [ ${#ALIYUN_TOKEN} -ne 32 ]; then
    echo "长度不对,阿里云盘 Token是32位长"
    echo -e "启动停止，请参考指南配置文件\nhttps://alist.nn.ci/zh/guide/drivers/aliyundrive.html \n"
    exit 1
else	
    echo "添加阿里云盘 Token..."
    echo "${ALIYUN_TOKEN}" > /data/mytoken.txt
fi

# 生成配置，阿里云open token
if [[ ${#ALIYUN_OPEN_TOKEN} -le 334 ]]; then
    echo "长度不对,阿里云盘 Open Token是335位"
    echo -e "安装停止，请参考指南配置文件\nhttps://alist.nn.ci/zh/guide/drivers/aliyundrive_open.html \n"
    exit 1
else
    echo "添加阿里云盘 Open Token..."
    echo "${ALIYUN_OPEN_TOKEN}" > /data/myopentoken.txt
fi

# 生成配置，阿里云转存目录folder_id
if [ ${#ALIYUN_FOLDER_ID} -ne 40 ]; then
    echo "长度不对,阿里云盘 folder id是40位长"
    echo -e "安装停止，请转存以下目录到你的网盘，并获取该文件夹的folder_id\nhttps://www.aliyundrive.com/s/rP9gP3h9asE \n"
    exit 1
else
    echo "添加阿里云盘 Folder ID..."
    echo "${ALIYUN_FOLDER_ID}" > /data/temp_transfer_folder_id.txt
fi

# 设置pikpak用户
if [ -n "${PIKPAK_LIST:-}" ]; then
    echo "设置PIKPAK用户密码..."
    rm -rf /data/pikpak_list.txt
    echo ${PIKPAK_LIST} | tr ',' '\n' | while read line; do
        user=$(echo $line | cut -d':' -f1)
        pass=$(echo $line | cut -d':' -f2-)
        echo "\"${user}\" \"${pass}\"" >> /data/pikpak_list.txt
    done
fi

# 开启强制登陆
if [ "${FORCE_LOGIN:=false}" = "true" ]; then
    echo "已开启强制登陆..."
    if [ ! -f /data/guestlogin.txt ]; then
        touch /data/guestlogin.txt
    fi
else
    echo "已关闭强制登陆..."
    rm -rf /data/guestlogin.txt
fi

# 设置webdav密码
if [ -n "${WEBDAV_PASSWORD:-}" ]; then
    echo "设置webdav密码..."
    echo "${WEBDAV_PASSWORD}" > /data/guestpass.txt
else
    rm -rf /data/guestpass.txt
fi

crond

crontabs=""

if [ "${AUTO_UPDATE_ENABLED:=false}" = "true" ]; then
    echo "启动定时更新定时任务..."
    crontabs="0 3 * * * /updateall"
fi

if [ "${AUTO_CLEAR_ENABLED:=false}" = "true" ]; then
    echo "启动定时清理定时任务..."
    crontabs="${crontabs}\n* */${AUTO_CLEAR_INTERVAL:=24} * * * /clear.sh"
fi

if [ -n "${crontabs}" ]; then
    echo -e "$crontabs" | crontab -
fi

# 设置本地变量
echo "e825ed6f7f8f44ffa0563cddaddce14d" > /data/infuse_api_key.txt

echo "${EMBY_ADDR:=http://emby:6908}" > /data/emby_server.txt

echo "${JELLYFIN_ADDR:=http://jellyfin:8096}" > /data/jellyfin_server.txt

exec /entrypoint.sh /opt/alist/alist server --no-prefix