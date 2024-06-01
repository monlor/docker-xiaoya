FROM xiaoyaliu/glue:latest

LABEL MAINTAINER me@monlor.com

WORKDIR /media

# 设置非交互模式，以避免安装过程中提示用户输入
ARG DEBIAN_FRONTEND=noninteractive

ENV LANG=zh_CN.UTF-8 \
    LANGUAGE=zh_CN:zh \
    LC_ALL=zh_CN.UTF-8

RUN apt-get update && \
    apt-get install -y cron locales fonts-wqy-zenhei software-properties-common && \
    locale-gen zh_CN.UTF-8 && \
    update-locale LANG=zh_CN.UTF-8 && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get install -y python3.12 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1 && \
    update-alternatives --config python3 && \
    curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12 && \
    apt-get remove -y software-properties-common && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* 
    

# 安装solid
RUN curl -#LO https://github.com/Rik-F5/xiaoya_db/archive/refs/heads/main.zip && \
    unzip main.zip && \
    pip install -r xiaoya_db-main/requirements.txt && \
    mv xiaoya_db-main/solid.py / && \
    rm -rf main.zip xiaoya_db-main

COPY --chmod=755 ./*.sh /

ENTRYPOINT [ "/entrypoint.sh" ]
