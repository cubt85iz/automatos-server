#!/bin/bash

set -euox pipefail

# Read repos for installation from json config.
readarray -t REPOS < <(jq -rc '.repos[]' /tmp/$CONFIG)

# Read packages for installation from json config.
readarray -t PACKAGES < <(jq -rc '.packages[]' /tmp/$CONFIG)

# Read containers for use from json config.
readarray -t CONTAINERS < <(jq -rc '.containers[]' /tmp/$CONFIG)

# Read SELinux boolean values from json config.
readarray -t SELINUX_BOOLEANS < <(jq -rc '.selinux.booleans[]' /tmp/$CONFIG)

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

# Remove containers, networks, services, & timers
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
rpm-ostree install "${PACKAGES[@]}"

# Configure SELinux global booleans
for BOOL in ${SELINUX_BOOLEANS[@]}; do
  NAME=$(echo $BOOL | jq -r '.name')
  VALUE=$(echo $BOOL | jq -r '.value')
  setsebool -P "$NAME" "$VALUE"
done
