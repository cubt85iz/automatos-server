#!/usr/bin/env bash

set -euxo pipefail

# Read repos for installation from json config.
readarray -t REPOS < <(jq -rc '.repos[]' /.config/$CONFIG)

# Read packages for installation from json config.
readarray -t PACKAGES < <(jq -rc '.packages[]' /.config/$CONFIG)

# Read containers for use from json config.
readarray -t CONTAINERS < <(jq -rc '.containers[]' /.config/$CONFIG)

# Read SELinux boolean values from json config.
readarray -t SELINUX_BOOLEANS < <(jq -rc '.selinux.booleans[]' /.config/$CONFIG)

# Output warning if the user has provided a configuration containing containers.
if [ "${#CONTAINERS[@]}" -gt 0 ]; then
  echo "WARNING: The provided configuration includes containers. Historically, this would " \
    "limit the list of provided container files to those specified. This is no longer the " \
    "case and the complete set of containers will be provided for each image. Update your " \
    "configuration to remove the specified containers and update your Butane configuration " \
    "to use symlinks to point to the container files you wish to run. More information can " \
    "be found in the automatos-server-config repository."
fi

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
