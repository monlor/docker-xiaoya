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

# 设置夸克网盘cookie
if [ -n "${QUARK_COOKIE:-}" ]; then
    echo "添加夸克网盘 Cookie..."
    echo "${QUARK_COOKIE}" > /data/quark_cookie.txt
else
    rm -rf /data/quark_cookie.txt
fi  

# 设置115 cookie
if [ -n "${PAN115_COOKIE:-}" ]; then
    echo "添加115网盘 Cookie..."
    echo "${PAN115_COOKIE}" > /data/115_cookie.txt
else
    rm -rf /data/115_cookie.txt
fi  

# 设置pikpak用户密码观看pikpak资源
if [ -n "${PIKPAK_USER:-}" ]; then
    echo "设置PIKPAK用户密码..."
    rm -rf /data/pikpak.txt
    user=$(echo "${PIKPAK_USER}" | cut -d':' -f1)
    pass=$(echo "${PIKPAK_USER}" | cut -d':' -f2-)
    echo "\"${user}\" \"${pass}\"" > /data/pikpak.txt
else
    rm -rf /data/pikpak.txt
fi

# 挂载你自己 pikpak 账号
if [ -n "${PIKPAK_LIST:-}" ]; then
    echo "挂载PIKPAK分享..."
    rm -rf /data/pikpak_list.txt
    echo "${PIKPAK_LIST}" | tr ',' '\n' | while read -r line; do
        name=$(echo "$line" | cut -d':' -f1)
        user=$(echo "$line" | cut -d':' -f2)
        pass=$(echo "$line" | cut -d':' -f3-)
        echo "${name} \"${user}\" \"${pass}\"" >> /data/pikpak_list.txt
    done
else
    rm -rf /data/pikpak_list.txt
fi

# 挂载pikpak分享，覆盖小雅的分享
if [ -n "${PIKPAK_SHARE_LIST:-}" ]; then
    echo "挂载额外的PIKPAK分享..."
    rm -rf /data/pikpakshare_list.txt
    echo "${PIKPAK_SHARE_LIST}" | tr ',' '\n' | while read -r line; do
        name=$(echo "$line" | cut -d':' -f1)
        share_id=$(echo "$line" | cut -d':' -f2)
        folder_id=$(echo "$line" | cut -d':' -f3)
        echo "${name} ${share_id} ${folder_id}" >> /data/pikpakshare_list.txt
    done
else
    rm -rf /data/pikpakshare_list.txt
fi

# 挂载额外的阿里云盘分享
if [ -n "${ALI_SHARE_LIST:-}" ]; then
    echo "挂载额外的PIKPAK分享..."
    rm -rf /data/alishare_list.txt
    echo "${ALI_SHARE_LIST}" | tr ',' '\n' | while read -r line; do
        name=$(echo "$line" | cut -d':' -f1)
        share_id=$(echo "$line" | cut -d':' -f2)
        folder_id=$(echo "$line" | cut -d':' -f3)
        echo "${name} ${share_id} ${folder_id}" >> /data/alishare_list.txt
    done
else
    rm -rf /data/alishare_list.txt
fi

# 挂载额外的夸克网盘分享
if [ -n "${QUARK_SHARE_LIST:-}" ]; then
    echo "挂载额外的夸克网盘分享..."
    rm -rf /data/quarkshare_list.txt
    echo "${QUARK_SHARE_LIST}" | tr ',' '\n' | while read -r line; do
        name=$(echo "$line" | cut -d':' -f1)
        share_id=$(echo "$line" | cut -d':' -f2)
        folder_id=$(echo "$line" | cut -d':' -f3)
        code=$(echo "$line" | cut -d':' -f4)
        echo "${name} ${share_id} ${folder_id} ${code}" >> /data/quarkshare_list.txt
    done
else
    rm -rf /data/quarkshare_list.txt
fi  

# 挂载额外的115网盘分享
if [ -n "${PAN115_SHARE_LIST:-}" ]; then
    echo "挂载额外的115网盘分享..."
    rm -rf /data/115share_list.txt
    echo "${PAN115_SHARE_LIST}" | tr ',' '\n' | while read -r line; do
        name=$(echo "$line" | cut -d':' -f1)
        share_id=$(echo "$line" | cut -d':' -f2)
        folder_id=$(echo "$line" | cut -d':' -f3)
        code=$(echo "$line" | cut -d':' -f4)
        echo "${name} ${share_id} ${folder_id} ${code}" >> /data/115share_list.txt
    done
else
    rm -rf /data/115share_list.txt
fi  

# 开启tvbox随机订阅
if [ "${TVBOX_SECURITY:=false}" = "true" ]; then
    echo "已开启TVBOX安全模式..."
    if [ ! -f /data/tvbox_security.txt ]; then
        touch /data/tvbox_security.txt
    fi
else
    echo "已关闭TVBOX安全模式..."
    rm -rf /data/tvbox_security.txt
fi

# 开启代理
if [ -n "${PROXY:-}" ]; then
    echo "已开启代理..."
    echo "${PROXY}" > /data/proxy.txt
else
    rm -rf /data/proxy.txt
fi

# 设置webdav密码
if [ -n "${WEBDAV_PASSWORD:-}" ]; then
    echo "设置webdav密码..."
    # 设置webdav密码后自动开启强制登陆
    echo "${WEBDAV_PASSWORD}" > /data/guestpass.txt
    if [ ! -f /data/guestlogin.txt ]; then
        touch /data/guestlogin.txt
    fi
else
    rm -rf /data/guestpass.txt
    # 关闭强制登陆
    rm -rf /data/guestlogin.txt
fi

# 设置数据下载目录
echo "http://127.0.0.1:5233/data" > /data/download_url.txt

crontabs=""

if [ "${AUTO_UPDATE_ENABLED:=false}" = "true" ]; then
    echo "启动定时更新定时任务..."
    # 随机生成一个时间，避免给服务器造成压力
    random_min=$(shuf -i 0-59 -n 1)
    random_hour=$(shuf -i 2-6 -n 1)
    crontabs="${random_min} ${random_hour} * * * /service.sh update"
fi

if [ "${AUTO_CLEAR_ENABLED:=false}" = "true" ]; then
    echo "启动定时清理定时任务..."
    AUTO_CLEAR_INTERVAL=${AUTO_CLEAR_INTERVAL:=10}
    HOURS=$(($AUTO_CLEAR_INTERVAL / 60))
    REMAINING_MINUTES=$(($AUTO_CLEAR_INTERVAL % 60))
    
    if [ $HOURS -gt 0 ]; then
      if [ $REMAINING_MINUTES -eq 0 ]; then
        CRONTAB_TIME="0 */$HOURS * * *"
      else
        CRONTAB_TIME="$REMAINING_MINUTES */$HOURS * * *"
      fi
    else
      CRONTAB_TIME="*/$REMAINING_MINUTES * * * *"
    fi
    crontabs="${crontabs}\n$CRONTAB_TIME /clear.sh"
    #crontabs="${crontabs}\n*/${AUTO_CLEAR_INTERVAL:=10} * * * * /clear.sh"
fi

# 添加后台守护
crontabs="${crontabs}\n* * * * * /service.sh daemon"

if [ -n "${crontabs}" ]; then
    echo -e "$crontabs" | crontab -
fi

# 设置本地变量
echo "${EMBY_APIKEY:-e825ed6f7f8f44ffa0563cddaddce14d}" > /data/infuse_api_key.txt

if [ "${AUTO_UPDATE_MEDIA_ADDR:=true}" = "true" ]; then
    echo "开始自动更新媒体服务地址..."
    /update_media_addr.sh &> /dev/null &
fi

/fix_media.sh &

/entrypoint.sh /opt/alist/alist server --no-prefix &

exec crond -f
