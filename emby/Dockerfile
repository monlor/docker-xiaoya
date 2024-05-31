FROM monlor/embyserver

LABEL MAINTAINER me@monlor.com

ARG TARGETARCH

ENV SHELL2HTTP_VERSION "1.17.0"

# emby自带的wget下载失败，只能用ADD
ADD https://github.com/msoap/shell2http/releases/download/v${SHELL2HTTP_VERSION}/shell2http_${SHELL2HTTP_VERSION}_linux_${TARGETARCH}.tar.gz .

RUN tar -zxvf shell2http_${SHELL2HTTP_VERSION}_linux_${TARGETARCH}.tar.gz -C /usr/bin/ shell2http && \
    rm -f shell2http_${SHELL2HTTP_VERSION}_linux_${TARGETARCH}.tar.gz

COPY ./entrypoint.sh /entrypoint.sh
COPY ./update_alist_addr.sh /update_alist_addr.sh

RUN chmod +x /entrypoint.sh /update_alist_addr.sh

ENTRYPOINT [ "/entrypoint.sh" ]