## 小雅影视库部署

![](https://cdn.monlor.com/2024/6/3/SCR-20240603-kpvb.jpeg)

[![Build Status](https://github.com/monlor/docker-xiaoya/actions/workflows/docker-build.yml/badge.svg)](https://github.com/monlor/docker-xiaoya/actions/workflows/docker-build.yml) [![repo size](https://img.shields.io/github/repo-size/monlor/docker-xiaoya.svg?style=flat)]() [![GitHub release (latest by date)](https://img.shields.io/github/v/release/monlor/docker-xiaoya)](https://github.com/monlor/docker-xiaoya/releases/latest) [![All Contributors](https://img.shields.io/badge/Contributors-3-orange.svg)](https://github.com/monlor/docker-xiaoya/graphs/contributors) [![](https://img.shields.io/badge/爱发电-monlor-purple)](https://afdian.net/a/monlor)


🚀 使用 Docker Compose 一键部署服务，兼容群晖，Linux，Windows，Mac，包含所有X86和Arm架构

✨ 部署alist+下载元数据+部署emby/jellyfin服务全流程自动，无需人工干预

* 所有脚本集成到 Docker 镜像，避免污染系统环境
* 合并jellyfin和emby的x86和arm镜像，部署时无需区分镜像名
* 集成云盘清理脚本到alist服务，无需单独部署
* 通过环境变量配置阿里云盘token，无需映射文件
* jellyfin和emby启动时自动进行依赖检查，等待元数据下载完成，自动添加hosts
* 完全兼容所有能运行docker的x86和arm设备
* 支持自动清理阿里云盘，自动同步小雅元数据
* 自动更新内部的alist，emby，jellyfin访问地址，无需手动配置
* 通过metadata服务自动更新emby配置和元数据

## 一键部署

### 部署或更新脚本

> 脚本支持重复执行

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/monlor/docker-xiaoya/main/install.sh)"
```

使用加速源（我的加速源也可能帮你减速🤣）

```bash
export GH_PROXY=https://gh.monlor.com/ IMAGE_PROXY=ghcr.monlor.com && bash -c "$(curl -fsSL ${GH_PROXY}https://raw.githubusercontent.com/monlor/docker-xiaoya/main/install.sh)"
```

### 卸载脚本

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/monlor/docker-xiaoya/main/uninstall.sh)"
```

使用加速源（我的加速源也可能帮你减速🤣）

```bash
export GH_PROXY=https://gh.monlor.com/ IMAGE_PROXY=ghcr.monlor.com && bash -c "$(curl -fsSL ${GH_PROXY}https://raw.githubusercontent.com/monlor/docker-xiaoya/main/uninstall.sh)"
```

### 自定义配置

【**非必须，小白跳过这一步**】脚本没有计划支持硬解，在我看来这个功能没有必要。如果你需要修改硬解，端口，数据目录，环境变量，请自行修改docker-compose.yml和env文件，修改完成后执行下面的命令，使配置生效。**修改后注意**：执行更新脚本会覆盖docker-compose.yml，不会覆盖env文件。

```bash
cd 你的安装目录
docker-compose up --remove-orphans -d
```

## 部署配置推荐

| 部署方案          | CPU      | 内存      | 硬盘      |
| ----------------- | -------- | --------- | --------- |
| Alist + Emby      | 2核   | 4G    | 150G  |
| 仅部署 Alist      | 1核   | 512M  | 512M  |
| Alist + Emby + Jellyfin      | 2核   | 4G    | 200G  |
| Alist + Jellyfin      | 2核   | 4G    | 150G  |

## 配置示例

* [只部署小雅alist](/docker-compose-alist.yml)
* [部署小雅alist+emby](/docker-compose.yml)
* [部署小雅alist+jellyfin](/docker-compose-jellyfin.yml)
* [部署小雅alist+emby+jellyfin](/docker-compose-all.yml)

## 服务组件介绍

* [Alist](/alist): 提供资源在线播放，WebDav服务
* [Metadata](/metadata): Emby和Jellyfin的元数据管理
* [Emby](/emby): 用家庭影视库的方式，可视化展示Alist中的资源
* [Jellyfin](/jellyfin): Emby的开源版本，功能是一样的

## 发烧友测试版

以下是测试版一键部署脚本，使用此脚本可以体验最新的功能，具体可以查看[commit](https://github.com/monlor/docker-xiaoya/commits/main/)更新了哪些测试版专属功能，**此脚本仅限发烧友使用，需要有一定的解决问题能力**

```bash
export VERSION=main && bash -c "$(curl -fsSL ${GH_PROXY}https://raw.githubusercontent.com/monlor/docker-xiaoya/${VERSION:-main}/install.sh)"
```

## 手动部署

仅展示小雅alist+emby的部署方式

### 使用Docker Compose

1. 创建compose文件夹

```bash
mkdir /opt/xiaoya
cd /opt/xiaoya
```

2. 下载配置

```bash
curl -#LO https://raw.githubusercontent.com/monlor/docker-xiaoya/main/docker-compose.yml
curl -#LO https://raw.githubusercontent.com/monlor/docker-xiaoya/main/env
```

3. 修改配置env里面的阿里云盘相关变量，启动服务

```bash
docker compose up -d
```

4. 查看日志

```bash
docker compose logs
```

### 使用docker部署【不推荐】

1. 创建volume

```bash
docker volume create xiaoya
docker volume create media
docker volume create config
docker volume create meta
docker volume create cache
```

2. 创建网络

```bash
docker network create xiaoya
```

3. 启动小雅alist，修改下面的阿里云盘配置，再执行命令

```bash
docker run -d --name alist \
    -v xiaoya:/data \
    -p 5678:5678 -p 2345:2345 -p 2346:2346 \
    -e TZ=Asia/Shanghai \
    -e ALIYUN_TOKEN=阿里云盘TOKEN \
    -e ALIYUN_OPEN_TOKEN=阿里云盘Open Token \
    -e ALIYUN_FOLDER_ID=阿里云盘文件夹ID \
    -e AUTO_UPDATE_ENABLED=true \
    -e AUTO_CLEAR_ENABLED=true \
    -e EMBY_ADDR=http://emby:6908 \
    --network=xiaoya \
    ghcr.io/monlor/xiaoya-alist 
```

4. 启动metadata用于元数据同步

```bash
docker run -d --name metadata \
    -e LANG=C.UTF-8 \
    -e EMBY_ENABLED=true \
    -e JELLYFIN_ENABLED=false \
    -e AUTO_UPDATE_EMBY_CONFIG_ENABLED=true \
    -e ALIST_ADDR=http://alist:5678 \
    -e EMBY_ADDR=http://emby:6908 \
    -v xiaoya:/etc/xiaoya \
    -v media:/media/xiaoya \
    -v config:/media/config \
    -v cache:/media/config/cache \
    -v meta:/media/temp \
    --network=xiaoya \
    ghcr.io/monlor/xiaoya-metadata
```

5. 启动emby服务

```bash
docker run -d --name emby
    -e TZ=Asia/Shanghai \
    -e GIDLIST=0 \
    -e ALIST_ADDR=http://alist:5678 \
    --privileged \
    --device /dev/dri:/dev/dri \
    -v media:/media \
    -v config:/config \
    -v cache:/cache \
    -p 6908:6908 \
    --network=xiaoya \
    ghcr.io/monlor/xiaoya-embyserver
```

6. 查看日志

```
docker logs alist
docker logs metadata
docker logs emby
```

## 安全建议

* 开启alist的登陆，alist服务设置`FORCE_LOGIN=true`，设置webdav的密码`WEBDAV_PASSWORD`
* 在emby控制台修改ApiKey，这个key需要配置到metadata和alist服务，变量名：`EMBY_APIKEY`

## 赞助

[![](https://img.shields.io/badge/爱发电-monlor-purple)](https://afdian.net/a/monlor)

## License

This project is licensed under the [Creative Commons Attribution-NonCommercial 4.0 International License](https://creativecommons.org/licenses/by-nc/4.0/).

## 参考

https://github.com/DDS-Derek/xiaoya-alist

https://www.kdocs.cn/l/cvEe3cv6dGkH

https://xiaoyaliu.notion.site/xiaoya-docker-69404af849504fa5bcf9f2dd5ecaa75f