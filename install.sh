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
if [[ ! " ${CONTAINERS[*]} " =~ [[:space:]]audiobookshelf[[:space:]] ]]; then
  rm audiobookshelf.container
fi
if [[ ! " ${CONTAINERS[*]} " =~ [[:space:]]beets[[:space:]] ]]; then
  rm beets.container
fi
if [[ ! " ${CONTAINERS[*]} " =~ [[:space:]]emby[[:space:]] ]]; then
  rm embyserver.container
fi
if [[ ! " ${CONTAINERS[*]} " =~ [[:space:]]gotify[[:space:]] ]]; then
  rm gotify.container
fi
if [[ ! " ${CONTAINERS[*]} " =~ [[:space:]]jellyfin[[:space:]] ]]; then
  rm jellyfin.container
fi
if [[ ! " ${CONTAINERS[*]} " =~ [[:space:]]lubelogger[[:space:]] ]]; then
  rm lubelogger.container
fi
if [[ ! " ${CONTAINERS[*]} " =~ [[:space:]]mealie[[:space:]] ]]; then
  rm mealie.container
fi
if [[ ! " ${CONTAINERS[*]} " =~ [[:space:]]minio[[:space:]] ]]; then
  rm minio.container
fi
if [[ ! " ${CONTAINERS[*]} " =~ [[:space:]]nextcloud[[:space:]] ]]; then
  rm nextcloud*.container
  pushd /etc/systemd/system/ &> /dev/null
  rm nextcloud*.{service,timer}
  popd &> /dev/null
fi
if [[ ! " ${CONTAINERS[*]} " =~ [[:space:]]plex[[:space:]] ]]; then
  rm plex*.{container,network}
fi
if [[ ! " ${CONTAINERS[*]} " =~ [[:space:]]pmm[[:space:]] ]]; then
  if [ -f plexmetamanager.container ]; then
    rm plexmetamanager.container
  fi
fi
if [[ ! " ${CONTAINERS[*]} " =~ [[:space:]]syncthing[[:space:]] ]]; then
  rm syncthing.container
fi
if [[ ! " ${CONTAINERS[*]} " =~ [[:space:]]unifi[[:space:]] ]]; then
  rm unifi*.{container,network}
fi
if [[ ! " ${CONTAINERS[*]} " =~ [[:space:]]ytsubs[[:space:]] ]]; then
  rm ytsubs.container
  rm /etc/systemd/system/ytsubs.timer
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
