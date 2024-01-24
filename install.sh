#!/bin/bash

set -euo pipefail

# Remove containers, networks, services, & timers
pushd /etc/containers/systemd/ &> /dev/null
if [ "${INCLUDE_AUDIOBOOKSHELF-}" != "y" ]; then
  rm audiobookshelf.container
fi
if [ "${INCLUDE_BEETS-}" != "y" ]; then
  rm beets.container
fi
if [ "${INCLUDE_EMBY-}" != "y" ]; then
  rm embyserver.container
fi
if [ "${INCLUDE_GOTIFY-}" != "y" ]; then
  rm gotify.container
fi
if [ "${INCLUDE_JELLYFIN-}" != "y" ]; then
  rm jellyfin.container
fi
if [ "${INCLUDE_LUBELOGGER-}" != "y" ]; then
  rm lubelogger.container
fi
if [ "${INCLUDE_MEALIE-}" != "y" ]; then
  rm mealie.container
fi
if [ "${INCLUDE_MINIO-}" != "y" ]; then
  rm minio.container
fi
if [ "${INCLUDE_NEXTCLOUD-}" != "y" ]; then
  rm nextcloud*.container
  pushd /etc/systemd/system/ &> /dev/null
  rm nextcloud*.{service,timer}
  popd &> /dev/null
fi
if [ "${INCLUDE_PLEX-}" != "y" ]; then
  rm plex*.{container,network}
fi
if [ "${INCLUDE_PMM-}" != "y" ]; then
  if [ -f plexmetamanager.container ]; then
    rm plexmetamanager.container
  fi
fi
if [ "${INCLUDE_SYNCTHING-}" != "y" ]; then
  rm syncthing.container
fi
if [ "${INCLUDE_UNIFI-}" != "y" ]; then
  rm unifi*.{container,network}
fi
if [ "${INCLUDE_YTSUBS-}" != "y" ]; then
  rm ytsubs.container
  rm /etc/systemd/system/ytsubs.timer
fi
popd &> /dev/null

# Override nfs to provide full utilities
rpm-ostree override remove nfs-utils-coreos --install nfs-utils

# Include additional packages
INCLUDED_PACKAGES=(borgbackup curl dbus-tools firewalld iwlegacy-firmware iwlwifi-dvm-firmware iwlwifi-mvm-firmware just nano podman rclone samba vim wget xdg-dbus-proxy xdg-user-dirs)
rpm-ostree install "${INCLUDED_PACKAGES[@]}"

# Configure samba
setsebool -P samba_export_all_rw 1
