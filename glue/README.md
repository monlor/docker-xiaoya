## 环境变量

`AUTO_UPDATE_EMBY_CONFIG_ENABLED`: 自动更新emby配置，下载config.mp4导入config，true/false，默认false

`AUTO_UPDATE_EMBY_INTERVAL`: 自动更新emby配置间隔，默认7，单位天

`EMBY_APIKEY`: emby api 密钥

`EMBY_URL`: emby地址，默认：http://emby:6908

`ALIST_ADDR`: alist地址，默认：http://alist:5678

## 手动更新emby配置

进入容器执行：`/update_emby.sh`