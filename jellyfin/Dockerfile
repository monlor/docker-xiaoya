FROM monlor/jellyfin

LABEL MAINTAINER me@monlor.com

COPY --chmod=755 ./entrypoint.sh /entrypoint.sh
COPY --chmod=755 ./update_alist_addr.sh /update_alist_addr.sh

ENTRYPOINT [ "/entrypoint.sh" ]