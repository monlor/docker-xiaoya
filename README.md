## 小雅影视库部署增强版

🚀 使用 Docker Compose 一键部署服务，兼容群晖，Linux，Windows，Mac，包含所有X86和Arm架构

✨ 部署alist+下载元数据+部署emby/jellyfin服务全流程自动，无需人工干预

* 所有脚本集成到 Docker 镜像，避免污染系统环境
* 合并jellyfin和emby的x86和arm镜像，部署时无需区分镜像名
* 集成清理脚本到alist服务，无需单独部署
* 通过环境变量配置阿里云盘token，无需映射文件
* 元数据下载的流程集成到glue服务，自动下载
* jellyfin和emby启动时自动进行依赖检查，等待元数据下载完成，自动添加hosts
* 完全兼容所有能运行docker的x86和arm设备
* 支持自动清理阿里云盘，自动同步小雅元数据
* resilio元数据同步自动配置，无需干预
* 自动更新内部的alist，emby，jellyfin访问地址，无需手动配置

## 一键部署

### 部署或更新脚本

> 脚本支持重复执行

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/monlor/docker-xiaoya/main/install.sh)"
```

### 卸载脚本

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/monlor/docker-xiaoya/main/uninstall.sh)"
```

## 部署配置推荐

| 部署方案          | CPU      | 内存      | 硬盘      |
| ----------------- | -------- | --------- | --------- |
| Alist + Emby      | 2核   | 4G    | 150G  |
| 仅部署 Alist      | 1核   | 512M  | 512M  |
| Alist + Emby + Jellyfin      | 2核   | 4G    | 300G  |
| Alist + Jellyfin      | 2核   | 4G    | 150G  |

## 配置示例

* [只部署小雅alist](/docker-compose-alist.yml)
* [部署小雅alist+emby](/docker-compose.yml)
* [部署小雅alist+jellyfin](/docker-compose-jellyfin.yml)
* [部署小雅alist+emby+jellyfin](/docker-compose-all.yml)

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
```

3. 修改配置docker-compose.yml，添加阿里云盘相关变量，启动服务

```bash
docker compose up -d
```

4. 卸载服务

```bash
docker compose down 
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
    --network=xiaoya \
    ghcr.io/monlor/xiaoya-alist 
```

4. 启动glue用于元数据同步

```bash
docker run -d --name glue \
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
    ghcr.io/monlor/xiaoya-glue
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
    ghcr.io/monlor/xiaoya-emby
```

6. 启动resilio自动同步元数据

```bash
docker run -d --name resilio \
    -e TZ=Asia/Shanghai \
    -p 8888:8888 -p 55555:55555 \
    -v media:/sync/xiaoya \
    -v config:/sync/config \
    --network=xiaoya \
    ghcr.io/monlor/xiaoya-resilio
```

## 参考

https://github.com/DDS-Derek/xiaoya-alist

https://www.kdocs.cn/l/cvEe3cv6dGkH

https://xiaoyaliu.notion.site/xiaoya-docker-69404af849504fa5bcf9f2dd5ecaa75f