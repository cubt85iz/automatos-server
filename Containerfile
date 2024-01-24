FROM ghcr.io/ublue-os/fedora-coreos:stable-zfs

ARG INCLUDE_AUDIOBOOKSHELF=${INCLUDE_AUDIOBOOKSHELF:-}
ARG INCLUDE_BEETS=${INCLUDE_BEETS:-}
ARG INCLUDE_EMBY=${INCLUDE_EMBY:-}
ARG INCLUDE_GOTIFY=${INCLUDE_GOTIFY:-}
ARG INCLUDE_JELLYFIN=${INCLUDE_JELLYFIN:-}
ARG INCLUDE_LUBELOGGER=${INCLUDE_LUBELOGGER:-}
ARG INCLUDE_MEALIE=${INCLUDE_MEALIE:-}
ARG INCLUDE_MINIO=${INCLUDE_MINIO:-}
ARG INCLUDE_NEXTCLOUD=${INCLUDE_NEXTCLOUD:-}
ARG INCLUDE_PLEX=${INCLUDE_PLEX:-}
ARG INCLUDE_PMM=${INCLUDE_PMM:-}
ARG INCLUDE_SYNCTHING=${INCLUDE_SYNCTHING:-}
ARG INCLUDE_UNIFI=${INCLUDE_UNIFI:-}
ARG INCLUDE_YTSUBS=${INCLUDE_YTSUBS:-}

COPY etc/ /etc/
COPY usr/ /usr/
COPY *.sh /tmp/

RUN mkdir -p /var/lib/alternatives \
    && /tmp/install.sh \
    && mv /var/lib/alternatives /staged-alternatives \
    && rm -fr /tmp/* /var/* \
    && ostree container commit \
    && mkdir -p /var/lib && mv /staged-alternatives /var/lib/alternatives \
    && mkdir -p /tmp /var/tmp \
    && chmod -R 1777 /tmp /var/tmp
