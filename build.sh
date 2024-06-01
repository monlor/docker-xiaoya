#!/bin/bash


docker build -t monlor/xiaoya-alist alist

docker build -t monlor/xiaoya-metadata metadata

docker build -t monlor/xiaoya-emby emby

docker build -t monlor/xiaoya-jellyfin jellyfin
