ARG BASE_IMAGE=ghcr.io/monlor/embyserver:latest

FROM alpine as base

RUN apk add dumb-init

FROM ${BASE_IMAGE}

LABEL MAINTAINER me@monlor.com

ENV TZ=Asia/Shanghai

ARG TARGETARCH

ENV PUID=0 PGID=0

COPY --chmod=755 --from=base /usr/bin/dumb-init /dumb-init

COPY --chmod=755 --from=msoap/shell2http:1.17.0 /app/shell2http /usr/bin/shell2http

COPY --chmod=755 ./*.sh /

ENTRYPOINT [ "/dumb-init", "/entrypoint.sh" ]