## 小雅影视库部署增强版

🚀 使用 Docker Compose 一键部署服务

✨ 部署alist+下载元数据+部署emby/jellyfin服务全流程自动，无需人工干预

* 所有脚本集成到 Docker 镜像，避免污染系统环境
* 合并jellyfin和emby的x86和arm镜像，部署时无需区分镜像名
* 集成清理脚本到alist服务，无需单独部署
* 通过环境变量配置阿里云盘token，无需映射文件
* 元数据下载的流程集成到glue服务，自动下载
* jellyfin和emby启动时自动进行依赖检查，等待元数据下载完成，自动添加hosts
* 完全兼容所有能运行docker的x86和arm设备
* 支持自动清理阿里云盘，自动同步小雅元数据

## 一键部署

建议最低配置：2核CPU 4G内存 150G硬盘

默认部署服务：alist + emby

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/monlor/docker-xiaoya/main/install.sh)"
```

## 配置示例

* [只部署小雅alist](/docker-compose-alist.yml)
* [部署小雅alist+jellyfin](/docker-compose-jellyfin.yml)
* [部署小雅alist+emby+jellyfin](/docker-compose-all.yml)

## 参考

https://github.com/DDS-Derek/xiaoya-alist

https://www.kdocs.cn/l/cvEe3cv6dGkH

https://xiaoyaliu.notion.site/xiaoya-docker-69404af849504fa5bcf9f2dd5ecaa75f