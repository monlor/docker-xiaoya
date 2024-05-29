FROM xiaoyaliu/alist:latest

LABEL MAINTAINER me@monlor.com
LABEL VERSION 1.1.0

EXPOSE 80 2345 2346

VOLUME /data

COPY ./start.sh /start.sh
COPY ./clear.sh /clear.sh

RUN chmod +x /start.sh /clear.sh

ENTRYPOINT [ "/start.sh" ]

CMD []