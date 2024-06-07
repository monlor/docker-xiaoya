ARG BASE_IMAGE=jellyfin/jellyfin:latest

FROM ${BASE_IMAGE}

LABEL MAINTAINER me@monlor.com

COPY --chmod=755 ./*.sh /

ENTRYPOINT [ "/entrypoint.sh" ]