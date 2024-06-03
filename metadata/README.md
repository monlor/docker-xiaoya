## 元数据管理

下载更新Emby和Jellyfin的元数据

## 环境变量

`AUTO_UPDATE_EMBY_CONFIG_ENABLED`: 自动更新emby配置，下载config.mp4导入config，true/false，默认false

`AUTO_UPDATE_EMBY_INTERVAL`: 自动更新emby配置间隔，默认7，单位天

`AUTO_UPDATE_METADATA_ENABLED`: 自动更新每日元数据，你们所说的爬虫，true/false，默认false

`EMBY_APIKEY`: emby api 密钥，建议修改emby的api密钥，设置此变量，用于定期同步emby配置

`EMBY_URL`: emby地址，默认：http://emby:6908

`ALIST_ADDR`: alist地址，默认：http://alist:5678

## emby数据管理

> 进入容器执行

更新emby配置数据

```
# 更新emby配置
/emby.sh update
# 使用历史config.mp4重置emby数据，无法恢复
/emby.sh reset
# 下载emby配置，仅下载，不更新
/emby.sh download
```

更新每日元数据

```
python3 /solid.py --media /media/xiaoya
```