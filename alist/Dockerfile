FROM xiaoyaliu/alist:hostmode

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.1.0

EXPOSE 5678 2345 2346

VOLUME /data

COPY ./start.sh /start.sh
COPY ./clear.sh /clear.sh
COPY ./update_media_addr.sh /update_media_addr.sh
COPY ./fix_media.sh /fix_media.sh

RUN chmod +x /start.sh /clear.sh /update_media_addr.sh /fix_media.sh

ENTRYPOINT [ "/start.sh" ]

CMD []