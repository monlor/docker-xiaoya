FROM monlor/embyserver

LABEL MAINTAINER me@monlor.com

ARG TARGETARCH

ENV SHELL2HTTP_VERSION "1.17.0"

ENV TINY_VERSION "v0.19.0"

# emby自带的wget下载失败，只能用ADD
ADD https://github.com/msoap/shell2http/releases/download/v${SHELL2HTTP_VERSION}/shell2http_${SHELL2HTTP_VERSION}_linux_${TARGETARCH}.tar.gz .
ADD https://github.com/krallin/tini/releases/download/${TINY_VERSION}/tini-${TARGETARCH} /tini

RUN tar -zxvf shell2http_${SHELL2HTTP_VERSION}_linux_${TARGETARCH}.tar.gz -C /usr/bin/ shell2http && \
    rm -f shell2http_${SHELL2HTTP_VERSION}_linux_${TARGETARCH}.tar.gz && \
    chmod +x /usr/bin/shell2http /tini

COPY ./entrypoint.sh /entrypoint.sh
COPY ./update_alist_addr.sh /update_alist_addr.sh

RUN chmod +x /entrypoint.sh /update_alist_addr.sh 

ENTRYPOINT [ "/tini", "--", "/entrypoint.sh" ]