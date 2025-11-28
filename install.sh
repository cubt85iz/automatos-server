#!/bin/bash

set -euox pipefail

# ref: https://github.com/ublue-os/ucore/ucore/install-ucore-minimal.sh
ARCH="$(rpm -E %{_arch})"
RELEASE="$(rpm -E %fedora)"

pushd /tmp/rpms/kernel &> /dev/null || exit 1
KERNEL_VERSION=$(find kernel-*.rpm | grep -P "kernel-(\d+\.\d+\.\d+)-.*\.fc${RELEASE}\.${ARCH}" | sed -E 's/kernel-//' | sed -E 's/\.rpm//')
popd &> /dev/null || exit 1

# always disable cisco-open264 repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-cisco-openh264.repo

# Install DNF5 Plugins
dnf -y install dnf5-plugins

# Replace Existing Kernel with packages from akmods cached kernel
for pkg in kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra; do
    if rpm -q $pkg >/dev/null 2>&1; then
        rpm --erase $pkg --nodeps
    fi
done
echo "Install kernel version ${KERNEL_VERSION} from kernel-cache."
dnf -y install \
    /tmp/rpms/kernel/kernel-[0-9]*.rpm \
    /tmp/rpms/kernel/kernel-core-*.rpm \
    /tmp/rpms/kernel/kernel-modules-*.rpm

# Ensure kernel packages can't be updated by other dnf operations
dnf versionlock add kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra

# Regenerate initramfs, for new kernel; not including NVIDIA or ZFS kmods
QUALIFIED_KERNEL="$(rpm -qa | grep -P 'kernel-(\d+\.\d+\.\d+)' | sed -E 's/kernel-//')"
/usr/bin/dracut --no-hostonly --kver "$QUALIFIED_KERNEL" --reproducible -v --add ostree -f "/lib/modules/$QUALIFIED_KERNEL/initramfs.img"
chmod 0600 "/lib/modules/$QUALIFIED_KERNEL/initramfs.img"

## ALWAYS: install ZFS (and sanoid deps)
# uCore does not support ZFS as rootfs, thus does not provide it in the initramfs
dnf -y install /tmp/rpms/akmods-zfs/kmods/zfs/*.rpm /tmp/rpms/akmods-zfs/kmods/zfs/other/zfs-dracut-*.rpm
# for some reason depmod ran automatically with zfs 2.1 but not with 2.2
echo "Update modules.dep, etc..."
depmod -a "${KERNEL_VERSION}"

## CONDITIONAL: install NVIDIA
if [[ "true" == "${INSTALL_NVIDIA}" ]]; then
    # uCore expects NVIDIA drivers are able to hot load/unload, thus does not provide it in the initramfs
    # repo for nvidia rpms
    curl --fail --retry 15 --retry-all-errors -sSL https://negativo17.org/repos/fedora-nvidia.repo -o /etc/yum.repos.d/fedora-nvidia.repo

    dnf -y install /tmp/rpms/akmods-nvidia/ucore/ublue-os-ucore-nvidia*.rpm
    sed -i '0,/enabled=0/{s/enabled=0/enabled=1/}' /etc/yum.repos.d/nvidia-container-toolkit.repo

    dnf -y install \
        /tmp/rpms/akmods-nvidia/kmods/kmod-nvidia*.rpm \
        nvidia-driver-cuda \
        nvidia-container-toolkit

    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/nvidia-container-toolkit.repo
    semodule --verbose --install /usr/share/selinux/packages/nvidia-container.pp
    systemctl enable ublue-nvctk-cdi.service
fi

## CONDITIONAL: install packages specific to x86_64
if [[ "x86_64" == "${ARCH}" ]]; then
    dnf -y install intel-compute-runtime
fi

# Read repos for installation from json config.
readarray -t REPOS < <(jq -rc '.repos[]' /config/$CONFIG)

# Read packages for installation from json config.
readarray -t PACKAGES < <(jq -rc '.packages[]' /config/$CONFIG)

# Read containers for use from json config.
readarray -t CONTAINERS < <(jq -rc '.containers[]' /config/$CONFIG)

# Read SELinux boolean values from json config.
readarray -t SELINUX_BOOLEANS < <(jq -rc '.selinux.booleans[]' /config/$CONFIG)

# Review container requirements for specified containers. If any
# requirements are not satisfied by the provided containers, then
# add them to the container list.
for CONTAINER in "${CONTAINERS[@]}"; do
  while read -r MATCH; do
    REQUIREMENTS=($(echo "${MATCH}" | awk -F= '{print $2}'))
    for REQUIREMENT in "${REQUIREMENTS[@]}"; do
      if ! [[ "${CONTAINERS[@]}" =~ ${REQUIREMENT} ]]; then
        if [ -f "/etc/containers/systemd/${REQUIREMENT%.*}.container" ]; then
          echo "Added ${REQUIREMENT} to list of containers."
          CONTAINERS+=("${REQUIREMENT}")
        fi
      fi
    done
  done < <(grep Requires "/etc/containers/systemd/${CONTAINER}.container")
done

# Remove containers & networks
pushd /etc/containers/systemd/ &> /dev/null
for CONTAINER_FILE in *.container; do
  CONTAINER=${CONTAINER_FILE%.*}
  if ! [[ "${CONTAINERS[@]}" =~ ${CONTAINER} ]]; then
    rm "${CONTAINER_FILE}"

    # Check for build unit
    if [ -f "${CONTAINER}.build" ]; then
      rm "${CONTAINER}.build"
    fi

    # Check for network
    if [ -f "${CONTAINER}.network" ]; then
      rm "${CONTAINER}.network"
    fi

    # Special cases
    # Caddy uses the proxy network
    if [ "${CONTAINER}" = "caddy" ]; then
      if [ -f "proxy.network" ]; then
        rm proxy.network
      fi
    fi

    # Nextcloud has a background service for performing tasks.
    if [ "${CONTAINER}" = "nextcloud" ]; then
      if [ -f "/etc/systemd/system/nextcloud-background.service" ]; then
        rm /etc/systemd/system/nextcloud-background.service
      fi
      if [ -f "/etc/systemd/system/nextcloud-background.timer" ]; then
        rm /etc/systemd/system/nextcloud-background.timer
      fi
      if [ -f "/etc/systemd/system/timers.target.wants/nextcloud-background.timer" ]; then
        rm /etc/systemd/system/timers.target.wants/nextcloud-background.timer
      fi
    fi

    # ProtonMail-Bridge uses the mail network
    if [ "${CONTAINER}" = "protonmail-bridge" ]; then
      if [ -f "mail.network" ]; then
        rm mail.network
      fi
    fi
    
    # Ollama uses the ai network
    if [ "${CONTAINER}" = "ollama" ]; then
      if [ -f "ai.network" ]; then
        rm ai.network
      fi
    fi
  fi
done

# Output remaining files for debugging
if [ "$DEBUG" = "true" ]; then
  cat <<EOF
Remaining files:
$(ls -1)
EOF
fi

popd &> /dev/null

# Override nfs to provide full utilities
rpm-ostree override remove nfs-utils-coreos --install nfs-utils

# Install repositories
for REPO in ${REPOS[@]}; do
  curl -sL "$REPO" | tee "/etc/yum.repos.d/${REPO##*/}"
done

# Install specified packages
if (( ${#PACKAGES[@]} > 0 )); then
  rpm-ostree install "${PACKAGES[@]}"
fi

# Configure SELinux global booleans
for BOOL in ${SELINUX_BOOLEANS[@]}; do
  NAME=$(echo $BOOL | jq -r '.name')
  VALUE=$(echo $BOOL | jq -r '.value')
  setsebool -P "$NAME" "$VALUE"
done
