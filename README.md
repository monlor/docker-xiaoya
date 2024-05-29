## 小雅影视库部署增强版

所有脚本集成到 Docker 镜像，避免污染系统环境

使用 Docker Compose 一键部署服务

## 部署

根据你的需求修改配置文件 docker-compose.yml，默认部署alist+emby+jellyfin

小雅alist的环境变量配置看[这里](/alist)

```bash
docker compose up -d
```

## 配置示例

* [只部署小雅alist](/docker-compose-alist.yml)
* [部署小雅alist+emby](/docker-compose-emby.yml)
* [部署小雅alist+jellyfin](/docker-compose-jellyfin.yml)

## 参考

https://hub.docker.com/r/amilys/embyserver

https://github.com/DDS-Derek/xiaoya-alist/blob/master/all_in_one.sh