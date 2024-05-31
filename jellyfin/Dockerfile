FROM monlor/jellyfin

LABEL MAINTAINER me@monlor.com

COPY ./entrypoint.sh /entrypoint.sh
COPY ./update_alist_addr.sh /update_alist_addr.sh

RUN chmod +x /entrypoint.sh /update_alist_addr.sh

ENTRYPOINT [ "/entrypoint.sh" ]