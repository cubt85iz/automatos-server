# Build arguments
ARG COREOS_STREAM=${COREOS_STREAM:-stable}
ARG FEDORA_VERSION=${FEDORA_VERSION:-43}
ARG REGISTRY=${REGISTRY:-quay.io/fedora/fedora-coreos}

# akmods from ublue-os/akmods
ARG AKMODS_COMMON="ghcr.io/ublue-os/akmods:coreos-${COREOS_STREAM}-${FEDORA_VERSION}"
ARG AKMODS_NVIDIA="ghcr.io/ublue-os/akmods-nvidia:coreos-${COREOS_STREAM}-${FEDORA_VERSION}"
ARG AKMODS_ZFS="ghcr.io/ublue-os/akmods-zfs:coreos-${COREOS_STREAM}-${FEDORA_VERSION}"
FROM ${AKMODS_COMMON} AS akmods-common
FROM ${AKMODS_NVIDIA} AS akmods-nvidia
FROM ${AKMODS_ZFS} AS akmods-zfs

FROM scratch AS context
ARG ROOT=${ROOT:-automatos-server}
COPY ./$ROOT/* /

FROM ${REGISTRY}:${COREOS_STREAM}

# Build arguments
ARG CONFIG=${CONFIG:-pow}
ARG DEBUG=${DEBUG:-false}
ARG INSTALL_NVIDIA=${INSTALL_NVIDIA:-false}
ARG ROOT=${ROOT:-automatos-server}

# Copy configuration files to image.
COPY $ROOT/etc/ /etc/
COPY $ROOT/usr/ /usr/

RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/cache/rpm-ostree \
    --mount=type=bind,from=context,src=/,dst=/context \
    --mount=type=bind,from=akmods-common,src=/rpms/ucore,dst=/tmp/rpms/akmods-common \
    --mount=type=bind,from=akmods-nvidia,src=/rpms,dst=/tmp/rpms/akmods-nvidia \
    --mount=type=bind,from=akmods-zfs,src=/rpms,dst=/tmp/rpms/akmods-zfs \
    --mount=type=bind,from=akmods-common,src=/kernel-rpms,dst=/tmp/rpms/kernel \
    /context/install.sh \
    && /ctx/cleanup.sh

RUN ["bootc", "container", "lint"]
