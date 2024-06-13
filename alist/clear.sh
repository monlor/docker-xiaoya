#!/bin/bash

set -e

DATA_DIR=/data
AUTO_CLEAR_THRESHOLD=${AUTO_CLEAR_THRESHOLD:-10}

retry_command() {
    # 重试次数和最大重试次数
    retries=0
    max_retries=10
    local cmd="$1"
    local success=false
    local output=""

    while ! $success && [ $retries -lt $max_retries ]; do
        output=$(eval "$cmd" 2>&1)
        if [ $? -eq 0 ]; then
            success=true
        else
            retries=$(($retries + 1))
            echo "#Failed to execute command \"$(echo "$cmd" | awk '{print $1}')\", retrying in 1 seconds (retry $retries of $max_retries)..." >&2
            sleep 1
        fi
    done

    if $success; then
        echo "$output"
        return 0
    else
        echo "#Failed to execute command after $max_retries retries: $cmd" >&2
        echo "#Command output: $output" >&2
        return 1
    fi
}

get_Header() {
    response=$(curl --connect-timeout 5 -m 5 -s -H "Content-Type: application/json" \
        -d '{"grant_type":"refresh_token", "refresh_token":"'$refresh_token'"}' \
        https://api.aliyundrive.com/v2/account/token)

    access_token=$(echo "$response" | sed -n 's/.*"access_token":"\([^"]*\).*/\1/p')

    HEADER="Authorization: Bearer $access_token"
    if [ -z "$HEADER" ]; then
        echo "获取access token失败" >&2
        return 1
    fi

    response="$(curl --connect-timeout 5 -m 5 -s -H "$HEADER" -H "Content-Type: application/json" -X POST -d '{}' "https://user.aliyundrive.com/v2/user/get")"

    lagacy_drive_id=$(echo "$response" | sed -n 's/.*"default_drive_id":"\([^"]*\).*/\1/p')

    drive_id=$(echo "$response" | sed -n 's/.*"resource_drive_id":"\([^"]*\).*/\1/p')

    if [ -z "$drive_id" ]; then
        drive_id=$lagacy_drive_id
    fi

    if [ "$folder_type"x = "b"x ]; then
        drive_id=$lagacy_drive_id
    fi

    if [ -z "$drive_id" ]; then
        echo "获取drive_id失败" >&2
        return 1
    fi

    echo "HEADER=\"$HEADER\""
    echo "drive_id=\"$drive_id\""
    return 0
}

get_rawList() {
    waittime=10
    if [ -n "$1" ]; then
        waittime="$1"
    fi
    _res=$(curl --connect-timeout 5 -m 5 -s -H "$HEADER" -H "Content-Type: application/json" -X POST -d '{"drive_id": "'$drive_id'","parent_file_id": "'$file_id'"}' "https://api.aliyundrive.com/adrive/v2/file/list")

    # 过滤掉最近的文件文件
    # 获取当前时间的 Unix 时间戳
    current_time=$(date +%s)
    # 定义时间间隔（30分钟）的秒数
    max_file_age_seconds=$((AUTO_CLEAR_THRESHOLD * 60))
    # 使用 jq 解析和筛选 JSON 数据
    _res=$(echo "$_res" | jq -c --argjson now "$current_time" --argjson interval "$max_file_age_seconds" '.items |= map(select(($now - ( .created_at | sub("\\.[0-9]+Z$"; "Z") | fromdateiso8601)) > $interval))')

    if [ ! $? -eq 0 ] || [ -z "$(echo "$_res" | grep "items")" ]; then
        echo "获取文件列表失败：folder_id=$file_id,drive_id=$drive_id" >&2
        return 1
    fi
    echo "$_res"
    #简单规避小雅转存后还没来得及获取直链就被删除的问题，降低发生概率
    sleep "$waittime"
    return 0
}

get_Path() {
    _path="$(curl --connect-timeout 5 -m 5 -s -H "$HEADER" -H "Content-Type: application/json" -X POST -d "{\"drive_id\": \"$drive_id\", \"file_id\": \"$file_id\"}" "https://api.aliyundrive.com/adrive/v1/file/get_path" | grep -o "\"name\":\"[^\"]*\"" | cut -d':' -f2- | tr -d '"' | tr '\n' '/' | awk -F'/' '{for(i=NF-1;i>0;i--){printf("/%s",$i)}; printf("%s\n",$NF)}')"
    if [ -z "$_path" ]; then
        return 1
    fi
    echo "$_path"
    return 0
}

get_List() {
    _res=$raw_list

    #echo "$_res" | tr '{' '\n' | grep -v "folder" | grep -o "\"file_id\":\"[^\"]*\"" | cut -d':' -f2- | tr -d '"'
    echo "$_res" | tr '{' '\n' | grep -o "\"file_id\":\"[^\"]*\"" | cut -d':' -f2- | tr -d '"'
    return 0
}

delete_File() {
    _file_id=$1
    _name="$(echo "$raw_list" | grep -o "\"name\":\"[^\"]*\"" | cut -d':' -f2- | tr -d '"' | grep -n . | grep "^$(echo "$raw_list" | grep -o "\"file_id\":\"[^\"]*\"" | cut -d':' -f2- | tr -d '"' | grep -n . | grep "$_file_id" | awk -F: '{print $1}'):" | awk -F: '{print $2}')"

    _res=$(curl --connect-timeout 5 -m 5 -s -H "$HEADER" -H "Content-Type: application/json" -X POST -d '{
  "requests": [
    {
      "body": {
        "drive_id": "'$drive_id'",
        "file_id": "'$_file_id'"
      },
      "headers": {
        "Content-Type": "application/json"
      },
      "id": "'$_file_id'",
      "method": "POST",
      "url": "/file/delete"
    }
  ],
  "resource": "file"
}' "https://api.aliyundrive.com/v3/batch" | grep "\"status\":204")
    if [ -z "$_res" ]; then
        return 1
    fi

    drive_root="资源盘"
    if [ "$folder_type"x = "b"x ]; then
        drive_root="备份盘"
    fi

    echo "彻底删除文件：/$drive_root$path/$_name"

    return 0
}

_clear_aliyun() {
    #eval "$(retry_command "get_Header")"
    raw_list=$(retry_command "get_rawList")
    path=$(retry_command "get_Path")
    _list="$(get_List)"
    echo "$_list" | sed '/^$/d' | while read line; do
        retry_command "delete_File \"$line\""
    done
    return "$(echo "$_list" | sed '/^$/d' | wc -l)"
}


clear_aliyun() {
    eval "$(retry_command "get_Header")"
    raw_list=$(retry_command "get_rawList 0")
    _list="$(get_List)"
    if [ -z "$(echo "$_list" | sed '/^$/d')" ]; then
        return 0
    fi

    echo -e "\n[$(date '+%Y/%m/%d %H:%M:%S')]开始清理小雅$XIAOYA_NAME转存"

    _res=1
    _filenum=0
    while [ ! $_res -eq 0 ]; do
        _clear_aliyun
        _res=$?
        _filenum=$(($_filenum + $_res))
    done

    echo "本次共清理小雅$XIAOYA_NAME转存文件$_filenum个"

}

init_para() {
    XIAOYA_NAME="alist"
    refresh_token="$(cat "${DATA_DIR}/mytoken.txt" | head -n1)"

    file_id=$(cat "${DATA_DIR}/temp_transfer_folder_id.txt")

    folder_type=$(cat "${DATA_DIR}/folder_type.txt")

    if [ -z "$refresh_token" ]; then
        echo "未找到refresh_token"
        return 1
    fi

    if [ -z "$file_id" ]; then
        echo "未找到file_id"
        return 1
    fi

    if [ -z "$folder_type" ]; then
        echo "未找到folder_type"
        return 1
    fi

}

init_para
clear_aliyun