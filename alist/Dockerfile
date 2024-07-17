FROM alpine as base

RUN apk add dumb-init

FROM xiaoyaliu/alist:hostmode

LABEL MAINTAINER me@monlor.com

ENV TZ=Asia/Shanghai

EXPOSE 5678 2345 2346

VOLUME /data

ARG TARGETARCH

RUN apk add --no-cache tzdata

COPY --chmod=755 --from=base /usr/bin/dumb-init /dumb-init

COPY --chmod=755 ./*.sh /

RUN /service.sh download

ENTRYPOINT [ "/dumb-init", "--", "/start.sh" ]

CMD []
