FROM monlor/embyserver

LABEL MAINTAINER me@monlor.com

ARG TARGETARCH

ENV SHELL2HTTP_VERSION "1.17.0"

ENV DUMB_INIT_VERSION "1.2.5"

ENV PUID=0 PGID=0

ADD https://github.com/msoap/shell2http/releases/download/v${SHELL2HTTP_VERSION}/shell2http_${SHELL2HTTP_VERSION}_linux_${TARGETARCH}.tar.gz .

COPY dumb-init_${DUMB_INIT_VERSION}_${TARGETARCH} /dumb-init

RUN tar -zxvf shell2http_${SHELL2HTTP_VERSION}_linux_${TARGETARCH}.tar.gz -C /usr/bin/ shell2http && \
    rm -rf shell2http_${SHELL2HTTP_VERSION}_linux_${TARGETARCH}.tar.gz && \
    chmod +x /dumb-init

COPY ./entrypoint.sh /entrypoint.sh
COPY ./update_alist_addr.sh /update_alist_addr.sh

RUN chmod +x /entrypoint.sh /update_alist_addr.sh 

ENTRYPOINT [ "/dumb-init", "/entrypoint.sh" ]