![docker-xiaoya](https://socialify.git.ci/monlor/docker-xiaoya/image?description=0&font=Rokkitt&forks=1&issues=1&language=1&logo=https%3A%2F%2Fcdn.monlor.com%2F2024%2F6%2F4%2F2024-06-04%252017.30.47.jpeg&name=1&owner=1&pattern=Circuit%20Board&pulls=1&stargazers=1&theme=Auto)

<div align="center">
<h2>小雅全家桶部署</h2>
<p><em>使用 Docker Compose 一键部署 Alist + Emby + Jellyfin</em></p>
</div>

<p align="center">
<a href="https://github.com/monlor/docker-xiaoya/actions/workflows/docker-build.yml"><img src="https://github.com/monlor/docker-xiaoya/actions/workflows/docker-build.yml/badge.svg" alt="Build Status"></a> 
<a><img src="https://img.shields.io/github/repo-size/monlor/docker-xiaoya.svg?style=flat" alt="repo size"></a> 
<a href="https://github.com/monlor/docker-xiaoya/releases/latest"><img src="https://img.shields.io/github/v/release/monlor/docker-xiaoya" alt="GitHub release (latest by date)"></a> 
<a href="https://github.com/monlor/docker-xiaoya/graphs/contributors"><img src="https://img.shields.io/badge/Contributors-6-orange.svg" alt="All Contributors"></a> 
<a href="https://buymeacoffee.com/monlor"><img src="https://img.shields.io/badge/Buy%20me%20a%20coffee-048754?logo=buymeacoffee" alt="buymeacoffee"></a>
</p>

## 功能特性

![](https://cdn.monlor.com/2024/6/4/SCR-20240603-kpvb.jpeg)

🚀 使用 Docker Compose 一键部署服务，兼容群晖，Linux，Windows，Mac，包含所有X86和Arm架构

✨ 部署alist+下载元数据+部署emby/jellyfin服务全流程自动，无需人工干预

* 所有脚本集成到 Docker 镜像，避免污染系统环境
* 合并jellyfin和emby的x86和arm镜像，部署时无需区分镜像名
* 自动清理阿里云盘，默认每10分钟一次
* 自动更新小雅alist中的云盘数据，默认每天一次
* 自动更新emby服务配置，默认每周一次
* 自动更新emby媒体数据，默认每天一次
* 支持小雅夸克网盘资源，挂载自定义夸克网盘资源
* 支持小雅PikPak网盘资源，挂载自定义PikPak资源
* 支持小雅阿里云盘资源，挂载自定义阿里云盘资源
* 支持WebDav，TvBox服务
* [Beta]适配Armv7设备，包括alist, emby和jellyfin

## 提问规则

1. 提BUG和需求，在 [Issues](https://github.com/monlor/docker-xiaoya/issues) 里提
2. 相关问题讨论或其他内容，在 [Discussions](https://github.com/monlor/docker-xiaoya/discussions) 里提

## 一键部署

### 部署或更新脚本

> 脚本支持重复执行

```bash
export VERSION=v1.2.14 && bash -c "$(curl -fsSL https://raw.githubusercontent.com/monlor/docker-xiaoya/main/install.sh)"
```

**使用加速源**

```bash
export VERSION=v1.2.14 GH_PROXY=https://gh.monlor.com/ IMAGE_PROXY=ghcr.monlor.com && bash -c "$(curl -fsSL ${GH_PROXY}https://raw.githubusercontent.com/monlor/docker-xiaoya/main/install.sh)"
```

**环境信息**

| 类型  | 地址 | 默认用户密码 |
| --- | --- | --- |
| alist | http://ip:5678 | - |
| webdav | http://ip:5678/dav | guest/guest_Api789 |
| tvbox | http://ip:5678/tvbox/my_ext.json | - |
| emby | http://ip:2345 | xiaoya/1234 |
| jellyfin | http://ip:2346 | ailg/5678 |

### 卸载脚本

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/monlor/docker-xiaoya/main/uninstall.sh)"
```

**使用加速源**

```bash
export GH_PROXY=https://gh.monlor.com/ IMAGE_PROXY=ghcr.monlor.com && bash -c "$(curl -fsSL ${GH_PROXY}https://raw.githubusercontent.com/monlor/docker-xiaoya/main/uninstall.sh)"
```

### 自定义配置

【**非必须，小白跳过这一步**】脚本没有计划支持硬解，在我看来这个功能没有必要。如果你需要修改硬解，端口，数据目录，环境变量，请自行修改docker-compose.yml和env文件，修改完成后执行下面的命令，使配置生效。**修改后注意**：执行更新脚本会覆盖docker-compose.yml，不会覆盖env文件。

```bash
cd 你的安装目录
docker-compose up --remove-orphans -d
```

### 发烧友测试版

以下是测试版一键部署脚本，使用此脚本可以体验最新的功能，具体可以查看[commit](https://github.com/monlor/docker-xiaoya/commits/main/)更新了哪些测试版专属功能，**此脚本仅限发烧友使用，需要有一定的解决问题能力**

```bash
export VERSION=main && bash -c "$(curl -fsSL ${GH_PROXY}https://raw.githubusercontent.com/monlor/docker-xiaoya/${VERSION:-main}/install.sh)"
```

## 部署配置推荐

| 部署方案          | CPU      | 内存      | 硬盘      |
| ----------------- | -------- | --------- | --------- |
| Alist + Emby      | 2核   | 4G    | 140G  |
| 仅部署 Alist      | 1核   | 512M  | 512M  |
| Alist + Emby + Jellyfin      | 4核   | 8G    | 300G  |
| Alist + Jellyfin      | 4核   | 8G    | 155G  |

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

### 部署在 Kubernetes

1. 安装helm

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

2. 安装helmfile

```bash
ver=0.161.0
curl -LO https://github.com/helmfile/helmfile/releases/download/v${ver}/helmfile_${ver}_linux_arm64.tar.gz
tar zxvf helmfile_${ver}_linux_arm64.tar.gz -C helmfile
mv helmfile/helmfile /usr/local/bin
rm -rf helmfile helmfile_${ver}_linux_arm64.tar.gz
helm plugin install https://github.com/databus23/helm-diff
```

3. 下载helmfile配置

```bash
curl -#LO https://raw.githubusercontent.com/monlor/docker-xiaoya/main/helmfile.yaml
```

4. 修改helmfile的环境变量，环境变量含义看这里[alist](/alist)

```yaml
env:
    ...
    WEBDAV_PASSWORD: 
    ALIYUN_TOKEN: 
    ALIYUN_OPEN_TOKEN: 
    ALIYUN_FOLDER_ID: 
    QUARK_COOKIE:
    PAN115_COOKIE:
    PIKPAK_USER:
    ...
```

5. 部署helm服务

```bash
helmfile sync -f helmfile.yaml
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
    -e QUARK_COOKIE=夸克网盘cookie \
    -e AUTO_UPDATE_ENABLED=true \
    -e AUTO_CLEAR_ENABLED=true \
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

* 开启alist的登陆，alist服务设置webdav的密码`WEBDAV_PASSWORD`
* 在emby控制台修改ApiKey，这个key需要配置到metadata和alist服务，变量名：`EMBY_APIKEY`

## 赞助

<a href="https://www.buymeacoffee.com/monlor" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>

## License

This project is licensed under the [Creative Commons Attribution-NonCommercial 4.0 International License](https://creativecommons.org/licenses/by-nc/4.0/).

## 参考

https://github.com/DDS-Derek/xiaoya-alist

https://www.kdocs.cn/l/cvEe3cv6dGkH

https://xiaoyaliu.notion.site/xiaoya-docker-69404af849504fa5bcf9f2dd5ecaa75f