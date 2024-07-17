#!/bin/bash

DATA_DIR="/www/data"

base_urls=(
    "https://gitlab.com/xiaoyaliu/data/-/raw/main"
    "https://raw.githubusercontent.com/xiaoyaliu00/data/main"
    "https://cdn.wygg.shop/https://raw.githubusercontent.com/xiaoyaliu00/data/main"
    "https://fastly.jsdelivr.net/gh/xiaoyaliu00/data@latest"
    "https://521github.com/extdomains/github.com/xiaoyaliu00/data/raw/main"
    "https://cors.zme.ink/https://raw.githubusercontent.com/xiaoyaliu00/data/main"
)

files=(
    "tvbox.zip"
    "update.zip"
    "index.zip"
    "version.txt"
)

if [ ! -d "$DATA_DIR" ]; then
    mkdir -p "$DATA_DIR"
fi

get_valid_url() {
    for url in "${base_urls[@]}"; do
        if curl -I -m 10 -s -f -o /dev/null "$url/version.txt"; then
            echo "$url"
            return 0
        fi
    done
    return 1
}

# 比较DATA_DIR本地version.txt版本号和远程version.txt版本号，不一样则下载文件
download_files() {
    remote_url=$(get_valid_url)
    if [ -z "$remote_url" ]; then
        echo "Failed to get valid url"
        return 1
    fi
    echo "Remote url: $remote_url"
    remote_version=$(curl -s "${remote_url}/version.txt")
    if [ -z "$remote_version" ]; then
        echo "Failed to get remote version"
        return 1
    fi
    local_version=""
    if [ -f "${DATA_DIR}/version.txt" ]; then
        local_version=$(cat "${DATA_DIR}/version.txt")
    fi
    if [ "$remote_version" != "$local_version" ]; then
        for file in "${files[@]}"; do
            echo "Downloading file $file..."
            curl -s -o "${DATA_DIR}/${file}" "${remote_url}/${file}"
        done
        return 0
    else
        echo "No need to download files"
        return 1
    fi
}

start() {
    /entrypoint.sh /opt/alist/alist server --no-prefix &
    sleep 30
    echo "1" > /tmp/status
}

stop() {
    echo "0" > /tmp/status
    kill -15 $(pgrep -f 'nginx|httpd|alist')
}

restart() {
    stop
    sleep 10
    start
}

update() {
    download_files
    restart
}

# 进程守护函数
daemon() {

    if [ -z "$(pgrep alist)" ] && [ "$(cat /tmp/status 2> /dev/null)" = "1" ]; then
        start
    fi

}

case "$1" in
    update)
        update
        ;;
    download)
        download_files
        ;;
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    daemon)
        daemon
        ;;
    *)
        echo "Usage: $0 {update|download}"
        exit 1
        ;;
esac
