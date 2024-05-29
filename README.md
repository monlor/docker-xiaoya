## 小雅影视库部署增强版

🚀 使用 Docker Compose 一键部署服务

✨ 部署alist+下载emby/jellyfin元数据+部署emby/jellyfin服务全流程自动，无需人工干预

* 所有脚本集成到 Docker 镜像，避免污染系统环境
* 合并jellyfin和emby的x86和arm镜像，部署时无需区分镜像名
* 集成清理脚本到alist服务，无需单独部署
* 通过环境变量配置阿里云盘token，无需映射文件
* 元数据下载的流程集成到glue服务，自动下载
* jellyfin和emby启动时自动进行依赖检查，等待元数据下载完成，自动添加hosts

## 部署

下载并修改配置文件 docker-compose.yml，默认配置部署alist+emby

部署emby大概要下载元数据60G，需要耐心等待下载完成

小雅alist的环境变量配置看[这里](/alist)

```bash
mkdir /opt/xiaoya && cd /opt/xiaoya
# 下载compose配置，修改变量ALIYUN_TOKEN，ALIYUN_OPEN_TOKEN，ALIYUN_FOLDER_ID
curl -LO https://raw.githubusercontent.com/monlor/docker-xiaoya/main/docker-compose.yml
docker compose up -d
```

## 配置示例

* [只部署小雅alist+emby](/docker-compose-alist.yml)
* [部署小雅alist+jellyfin](/docker-compose-jellyfin.yml)
* [部署小雅alist+emby+jellyfin](/docker-compose-all.yml)

## 参考

https://hub.docker.com/r/amilys/embyserver

https://github.com/DDS-Derek/xiaoya-alist/blob/master/all_in_one.sh