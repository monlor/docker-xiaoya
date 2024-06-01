FROM xiaoyaliu/alist:hostmode

LABEL MAINTAINER me@monlor.com

EXPOSE 5678 2345 2346

VOLUME /data

ARG TARGETARCH

ENV DUMB_INIT_VERSION "1.2.5"

ADD https://raw.githubusercontent.com/monlor/docker-xiaoya/main/bin/dumb-init_${DUMB_INIT_VERSION}_${TARGETARCH} /dumb-init

RUN chmod +x /dumb-init

COPY ./start.sh /start.sh
COPY ./clear.sh /clear.sh
COPY ./update_media_addr.sh /update_media_addr.sh
COPY ./fix_media.sh /fix_media.sh
COPY ./data.sh /data.sh

RUN chmod +x /start.sh /clear.sh /update_media_addr.sh /fix_media.sh /data.sh 

RUN DATA_DIR=/tmp/data /data.sh download

ENTRYPOINT [ "/dumb-init", "--", "/start.sh" ]

CMD []