# Build arguments
ARG COREOS_VERSION
ARG FEDORA_VERSION
ARG REGISTRY=${REGISTRY:-quay.io/fedora/fedora-coreos}
ARG UCORE_STREAM=${UCORE_STREAM:-stable}

# akmods from ublue-os/akmods
ARG AKMODS_NVIDIA="ghcr.io/ublue-os/akmods-nvidia-open:coreos-${UCORE_STREAM}-${FEDORA_VERSION}"
ARG AKMODS_ZFS="ghcr.io/ublue-os/akmods-zfs:coreos-${UCORE_STREAM}-${FEDORA_VERSION}"
FROM ${AKMODS_NVIDIA} AS akmods-nvidia
FROM ${AKMODS_ZFS} AS akmods-zfs


FROM docker.io/library/ubuntu:latest AS prebuild
ARG ROOT=${ROOT:-automatos-server}
COPY ./$ROOT/configure.sh /
RUN apt-get update \
    && apt-get -y install curl \
    && curl --fail --retry 15 --retry-all-errors -sSL https://raw.githubusercontent.com/ublue-os/ucore/refs/heads/main/ucore/cleanup.sh -o /cleanup.sh \
    && curl --fail --retry 15 --retry-all-errors -sSL https://raw.githubusercontent.com/ublue-os/ucore/refs/heads/main/ucore/install-ucore-minimal.sh -o /install-ucore-minimal.sh \
    && curl --fail --retry 15 --retry-all-errors -sSL https://raw.githubusercontent.com/ublue-os/ucore/refs/heads/main/ucore/install-ucore-minimal-nvidia.sh -o /install-nvidia.sh \
    && sed -n '1,/^##\s*ALWAYS:\s*install regular packages/p' /install-ucore-minimal.sh > /install.sh \
    && rm /install-ucore-minimal.sh \
    && chmod +x /install.sh /install-nvidia.sh /cleanup.sh


FROM ${REGISTRY}:${COREOS_VERSION}

# Build arguments
ARG COREOS_VERSION
ARG CONFIG=${CONFIG:-pow}
ARG KERNEL_FLAVOR=${KERNEL_FLAVOR:-}
ARG NVIDIA_FLAVOR=${NVIDIA_FLAVOR:-nvidia-open}
ARG NVIDIA_TAG=${NVIDIA_TAG:-}
ARG UCORE_STREAM=${UCORE_STREAM:-stable}
ARG ROOT=${ROOT:-automatos-server}

# Copy configuration files to image.
COPY $ROOT/etc/ /etc/
COPY $ROOT/opt/ /opt/
COPY $ROOT/usr/ /usr/

RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/cache/rpm-ostree \
    --mount=type=bind,from=akmods-nvidia,src=/rpms,dst=/tmp/rpms/akmods-nvidia \
    --mount=type=bind,from=akmods-zfs,src=/rpms,dst=/tmp/rpms/akmods-zfs \
    --mount=type=bind,from=akmods-zfs,src=/kernel-rpms,dst=/tmp/rpms/kernel \
    --mount=type=bind,from=prebuild,src=/,dst=/prebuild \
    --mount=type=bind,src=.config/,dst=/.config,Z \
    /prebuild/install.sh \
    && /prebuild/install-nvidia.sh \
    # Eliminate After directive to eliminate startup issues.
    && sed -i 's|After=multi-user.target|# &|' /etc/systemd/system/nvidia-cdi-refresh.service \
    && /prebuild/configure.sh \
    && /prebuild/cleanup.sh

RUN ["bootc", "container", "lint"]
