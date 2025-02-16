FROM ghcr.io/ublue-os/fedora-coreos:stable-zfs

ARG CONFIG=${CONFIG:-pow}
ARG DEBUG=${DEBUG:-false}

COPY etc/ /etc/
COPY usr/ /usr/
COPY *.sh /tmp/
COPY .config/$CONFIG /tmp/

RUN mkdir -p /var/lib/alternatives \
    && /tmp/install.sh \
    && mv /var/lib/alternatives /staged-alternatives \
    && rm -fr /tmp/* /var/* \
    && ostree container commit \
    && mkdir -p /var/lib && mv /staged-alternatives /var/lib/alternatives \
    && mkdir -p /tmp /var/tmp \
    && chmod -R 1777 /tmp /var/tmp
