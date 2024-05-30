FROM linuxserver/resilio-sync:2.8.0

COPY ./config.tar.gz /config.tar.gz

RUN tar -zxvf /config.tar.gz --strip-components=1 -C /config && rm -rf /config.tar.gz

COPY ./entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]