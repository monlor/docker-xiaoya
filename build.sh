#!/bin/bash


docker build -t monlor/xiaoya-alist alist

docker build -t monlor/xiaoya-glue glue

docker build -t monlor/xiaoya-emby emby

docker build -t monlor/xiaoya-jellyfin jellyfin
