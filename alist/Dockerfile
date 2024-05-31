FROM xiaoyaliu/alist:hostmode

LABEL MAINTAINER me@monlor.com

EXPOSE 5678 2345 2346

VOLUME /data

COPY ./start.sh /start.sh
COPY ./clear.sh /clear.sh
COPY ./update_media_addr.sh /update_media_addr.sh

RUN chmod +x /start.sh /clear.sh /update_media_addr.sh 

ENTRYPOINT [ "/start.sh" ]

CMD []