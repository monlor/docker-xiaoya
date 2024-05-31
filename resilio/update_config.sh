#!/bin/bash

docker run -d --name xiaoya-resilio  -p 8888:8888 docker.io/monlor/xiaoya-resilio 

docker exec xiaoya-resilio mkdir /sync/config
docker exec xiaoya-resilio touch /sync/config/emby_meta_finished

echo "Server started. accessing the webui at http://localhost:8888"

read -p "Press any key to overwrite the config file..."

rm -rf config.tar.gz

docker stop xiaoya-resilio
docker cp xiaoya-resilio:/config ./config
docker rm xiaoya-resilio

tar zcvf config.tar.gz config
rm -rf config