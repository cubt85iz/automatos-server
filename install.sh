#!/bin/bash

set -euox pipefail

# Read packages for installation from json config.
readarray -t PACKAGES < <(jq -rc '.packages[]' /tmp/$CONFIG)

# Read containers for use from json config.
readarray -t CONTAINERS < <(jq -rc '.containers[]' /tmp/$CONFIG)

# Read SELinux boolean values from json config.
readarray -t SELINUX_BOOLEANS < <(jq -rc '.selinux.booleans[]' /tmp/$CONFIG)

# Remove containers, networks, services, & timers
pushd /etc/containers/systemd/ &> /dev/null
for CONTAINER_FILE in *.container; do
  CONTAINER=${CONTAINER_FILE%.*}
  if ! [[ "${CONTAINERS[@]}" =~ ${CONTAINER} ]]; then
    rm "${CONTAINER_FILE}"

    # Check for network
    if [ -f "${CONTAINER}.network" ]; then
      rm "${CONTAINER}.network"
    fi

    # Check for timer & symlink
    if [ -f "/etc/systemd/system/${CONTAINER}.timer" ]; then
      rm "/etc/systemd/system/${CONTAINER}.timer"
      if [ -f "/etc/systemd/system/timers.target.wants/${CONTAINER}.timer" ]; then
        rm "/etc/systemd/system/timers.target.wants/${CONTAINER}.timer"
      fi
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

# Install specified packages
rpm-ostree install "${PACKAGES[@]}"

# Configure SELinux global booleans
for BOOL in ${SELINUX_BOOLEANS[@]}; do
  NAME=$(echo $BOOL | jq -r '.name')
  VALUE=$(echo $BOOL | jq -r '.value')
  setsebool -P "$NAME" "$VALUE"
done
