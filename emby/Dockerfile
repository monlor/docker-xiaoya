ARG BASE_IMAGE=ghcr.io/monlor/embyserver:latest

FROM ${BASE_IMAGE}

LABEL MAINTAINER me@monlor.com

ENV TZ=Asia/Shanghai

ARG TARGETARCH

ENV SHELL2HTTP_VERSION="1.17.0" \
    DUMB_INIT_VERSION="1.2.5"

ENV PUID=0 PGID=0

ADD https://github.com/msoap/shell2http/releases/download/v${SHELL2HTTP_VERSION}/shell2http_${SHELL2HTTP_VERSION}_linux_${TARGETARCH}.tar.gz .

ADD --chmod=755 https://raw.githubusercontent.com/monlor/docker-xiaoya/main/bin/dumb-init_${DUMB_INIT_VERSION}_${TARGETARCH} /dumb-init

RUN tar -zxvf shell2http_${SHELL2HTTP_VERSION}_linux_${TARGETARCH}.tar.gz -C /usr/bin/ shell2http && \
    rm -rf shell2http_${SHELL2HTTP_VERSION}_linux_${TARGETARCH}.tar.gz

COPY --chmod=755 ./*.sh /

ENTRYPOINT [ "/dumb-init", "/entrypoint.sh" ]