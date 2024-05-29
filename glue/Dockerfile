FROM xiaoyaliu/glue:latest

WORKDIR /media

RUN apt update && apt install -y cron

COPY ./entrypoint.sh /entrypoint.sh
COPY ./update_emby.sh /update.sh

RUN chmod +x /entrypoint.sh /update_emby.sh

ENTRYPOINT [ "/entrypoint.sh" ]