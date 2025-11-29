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

FROM scratch AS ctx
ARG ROOT=${ROOT:-automatos-server}
COPY ./$ROOT/* /

FROM docker.io/library/alpine:latest AS prebuild
RUN apk add --no-cache curl \
    && curl --fail --retry 15 --retry-all-errors -sSL https://raw.githubusercontent.com/ublue-os/ucore/refs/heads/main/ucore/cleanup.sh -o /cleanup.sh \
    && curl --fail --retry 15 --retry-all-errors -sSL https://raw.githubusercontent.com/ublue-os/ucore/refs/heads/main/ucore/install-ucore-minimal.sh -o /install.sh \
    && sed -n '1,/^##\s*ALWAYS:\s*install regular packages/p' /install.sh > /install.sh \
    && chmod +x /install.sh /cleanup.sh


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
    --mount=type=bind,from=ctx,src=/,dst=/ctx \
    --mount=type=bind,from=akmods-common,src=/rpms/ucore,dst=/tmp/rpms/akmods-common \
    --mount=type=bind,from=akmods-nvidia,src=/rpms,dst=/tmp/rpms/akmods-nvidia \
    --mount=type=bind,from=akmods-zfs,src=/rpms,dst=/tmp/rpms/akmods-zfs \
    --mount=type=bind,from=akmods-common,src=/kernel-rpms,dst=/tmp/rpms/kernel \
    --mount=type=bind,from=prebuild,src=/,dst=/prebuild \
    --mount=type=bind,src=.config/,dst=/.config,Z \
    /prebuild/install.sh \
    && /ctx/configure.sh \
    && /prebuild/cleanup.sh

RUN ["bootc", "container", "lint"]
