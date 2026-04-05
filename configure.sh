#!/usr/bin/env bash

set -euxo pipefail

# Read repos for installation from json config.
readarray -t REPOS < <(jq -rc '.repos[]' /.config/$CONFIG)

# Read packages for installation from json config.
readarray -t PACKAGES < <(jq -rc '.packages[]' /.config/$CONFIG)

# Read SELinux boolean values from json config.
readarray -t SELINUX_BOOLEANS < <(jq -rc '.selinux.booleans[]' /.config/$CONFIG)

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
