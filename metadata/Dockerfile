FROM xiaoyaliu/metadata:latest

WORKDIR /media

# 设置非交互模式，以避免安装过程中提示用户输入
ARG DEBIAN_FRONTEND=noninteractive

ENV LANG=zh_CN.UTF-8 \
    LANGUAGE=zh_CN:zh \
    LC_ALL=zh_CN.UTF-8

RUN apt-get update && \
    apt-get install -y cron locales fonts-wqy-zenhei && \
    locale-gen zh_CN.UTF-8 && \
    update-locale LANG=zh_CN.UTF-8 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh /entrypoint.sh
COPY ./emby.sh /emby.sh

RUN chmod +x /entrypoint.sh /emby.sh

ENTRYPOINT [ "/entrypoint.sh" ]