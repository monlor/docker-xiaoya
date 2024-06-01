FROM xiaoyaliu/alist:hostmode

LABEL MAINTAINER me@monlor.com

EXPOSE 5678 2345 2346

VOLUME /data

ARG TARGETARCH

ENV DUMB_INIT_VERSION "1.2.5"

ADD --chmod=755 https://raw.githubusercontent.com/monlor/docker-xiaoya/main/bin/dumb-init_${DUMB_INIT_VERSION}_${TARGETARCH} /dumb-init

COPY --chmod=755 ./*.sh /

RUN DATA_DIR=/tmp/data /data.sh download

ENTRYPOINT [ "/dumb-init", "--", "/start.sh" ]

CMD []
