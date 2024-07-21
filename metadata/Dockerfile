FROM python:3.12-slim

LABEL MAINTAINER me@monlor.com

ENV TZ=Asia/Shanghai

WORKDIR /media

# 设置非交互模式，以避免安装过程中提示用户输入
ARG DEBIAN_FRONTEND=noninteractive

ENV LANG=C.UTF-8

RUN apt-get update && \
    apt-get install -y cron locales fonts-wqy-zenhei busybox unzip curl fd-find gzip lsof sqlite3 httpie jq tzdata aria2 p7zip-full && \
    locale-gen C.UTF-8 && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/*

# 安装solid
RUN curl -#LO https://gh.monlor.com/https://github.com/Rik-F5/xiaoya_db/archive/refs/heads/main.zip && \
    unzip main.zip && \
    pip install -r xiaoya_db-main/requirements.txt && \
    mv xiaoya_db-main/solid.py / && \
    rm -rf main.zip xiaoya_db-main

COPY --chmod=755 ./*.sh /

ENTRYPOINT [ "/entrypoint.sh" ]
