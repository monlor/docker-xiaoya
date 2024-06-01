#!/bin/bash

service="$1"
services=(
    "alist"
    "emby"
    "jellyfin"
    "metadata"
)

if [ -z "$service" ]; then
    for service in ${services[@]}; do
        docker build -t monlor/xiaoya-$service $service
    done
else
    docker build -t monlor/xiaoya-$service $service
fi

