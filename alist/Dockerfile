FROM xiaoyaliu/alist:hostmode

LABEL MAINTAINER me@monlor.com

EXPOSE 5678 2345 2346

VOLUME /data

ARG TARGETARCH

ENV TINY_VERSION "v0.19.0"

RUN curl -#Lo /tini https://github.com/krallin/tini/releases/download/${TINY_VERSION}/tini-${TARGETARCH} && \
    chmod +x /tini

COPY ./start.sh /start.sh
COPY ./clear.sh /clear.sh
COPY ./update_media_addr.sh /update_media_addr.sh
COPY ./fix_media.sh /fix_media.sh
COPY ./data.sh /data.sh

RUN chmod +x /start.sh /clear.sh /update_media_addr.sh /fix_media.sh /data.sh 

RUN DATA_DIR=/tmp/data /data.sh download

ENTRYPOINT [ "/tini", "--", "/start.sh" ]

CMD []