ARG BASE_IMAGE=jellyfin/jellyfin:latest

FROM ${BASE_IMAGE}

LABEL MAINTAINER me@monlor.com

ENV TZ=Asia/Shanghai

# 更新软件包索引、安装 ping 命令并清理缓存
RUN apt-get update \
    && apt-get install -y iputils-ping \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --chmod=755 ./*.sh /

ENTRYPOINT [ "/entrypoint.sh" ]