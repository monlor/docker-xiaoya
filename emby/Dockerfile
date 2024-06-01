FROM monlor/embyserver

LABEL MAINTAINER me@monlor.com

ARG TARGETARCH

ENV SHELL2HTTP_VERSION "1.17.0"

ENV DUMB_INIT_VERSION "1.2.5"

ENV PUID=0 PGID=0

RUN wget https://github.com/msoap/shell2http/releases/download/v${SHELL2HTTP_VERSION}/shell2http_${SHELL2HTTP_VERSION}_linux_${TARGETARCH}.tar.gz && \
    tar -zxvf shell2http_${SHELL2HTTP_VERSION}_linux_${TARGETARCH}.tar.gz -C /usr/bin/ shell2http && \
    rm -rf shell2http_${SHELL2HTTP_VERSION}_linux_${TARGETARCH}.tar.gz && \
    [ ${TARGETARCH} = "arm64" ] && ARCH="aarch64" && \
    [ ${TARGETARCH} = "amd64" ] && ARCH="x86_64" && \
    wget -O /dumb-init https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VERSION}/dumb-init_${DUMB_INIT_VERSION}_${ARCH} && \
    chmod +x /dumb-init

COPY ./entrypoint.sh /entrypoint.sh
COPY ./update_alist_addr.sh /update_alist_addr.sh

RUN chmod +x /entrypoint.sh /update_alist_addr.sh 

ENTRYPOINT [ "/dumb-init", "/entrypoint.sh" ]