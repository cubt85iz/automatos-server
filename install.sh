#!/bin/bash

set -euo pipefail

# Define deployment suites
if [ -n "$DEPLOY_SUITE" ]; then
  if [ "$DEPLOY_SUITE" == "all" ]; then
    # Include everything
    INCLUDE_AUDIOBOOKSHELF=y
    INCLUDE_BEETS=y
    INCLUDE_EMBY=y
    INCLUDE_GOTIFY=y
    INCLUDE_JELLYFIN=y
    INCLUDE_LUBELOGGER=y
    INCLUDE_MEALIE=y
    INCLUDE_MINIO=y
    INCLUDE_NEXTCLOUD=y
    INCLUDE_PLEX=y
    INCLUDE_PMM=y
    INCLUDE_SYNCTHING=y
    INCLUDE_UNIFI=y
    INCLUDE_YTSUBS=y
  elif [ "$DEPLOY_SUITE" == "nnk" ]; then
    INCLUDE_SYNCTHING=y
  elif [ "$DEPLOY_SUITE" == "pow" ]; then
    INCLUDE_AUDIOBOOKSHELF=y
    INCLUDE_BEETS=y
    INCLUDE_EMBY=y
    INCLUDE_GOTIFY=y
    INCLUDE_LUBELOGGER=y
    INCLUDE_MEALIE=y
    INCLUDE_NEXTCLOUD=y
    INCLUDE_PLEX=y
    INCLUDE_PMM=y
    INCLUDE_SYNCTHING=y
    INCLUDE_UNIFI=y
  else
    echo "ERROR: Deployment suite not recognized ($DEPLOY_SUITE)."
    exit 1
  fi
else
  echo "ERROR: Deployment suite not provided."
  exit 1
fi

# Remove quadlet containers & networks
pushd /etc/containers/systemd/ &> /dev/null
if [ -z "${INCLUDE_AUDIOBOOKSHELF-}" ]; then
  rm audiobookshelf.container
fi
if [ -z "${INCLUDE_BEETS-}" ]; then
  rm beets.container
fi
if [ -z "${INCLUDE_EMBY-}" ]; then
  rm embyserver.container
fi
if [ -z "${INCLUDE_GOTIFY-}" ]; then
  rm gotify.container
fi
if [ -z "${INCLUDE_JELLYFIN-}" ]; then
  rm jellyfin.container
fi
if [ -z "${INCLUDE_LUBELOGGER-}" ]; then
  rm lubelogger.container
fi
if [ -z "${INCLUDE_MEALIE-}" ]; then
  rm mealie.container
fi
if [ -z "${INCLUDE_MINIO-}" ]; then
  rm minio.container
fi
if [ -z "${INCLUDE_NEXTCLOUD-}" ]; then
  rm nextcloud*.container
  pushd /etc/systemd/system/ &> /dev/null
  rm nextcloud*.{service,timer}
  popd &> /dev/null
fi
if [ -z "${INCLUDE_PLEX-}" ]; then
  rm plex*.{container,network}
fi
if [ -z "${INCLUDE_PMM-}" ]; then
  if [ -f plexmetamanager.container ]; then
    rm plexmetamanager.container
  fi
fi
if [ -z "${INCLUDE_SYNCTHING-}" ]; then
  rm syncthing.container
fi
if [ -z "${INCLUDE_UNIFI-}" ]; then
  rm unifi*.{container,network}
fi
if [ -z "${INCLUDE_YTSUBS-}" ]; then
  rm ytsubs.container
  rm /etc/systemd/system/ytsubs.timer
fi
popd &> /dev/null

rpm-ostree override remove nfs-utils-coreos --install nfs-utils

INCLUDED_PACKAGES=(borgbackup curl dbus-tools firewalld iwlegacy-firmware iwlwifi-dvm-firmware iwlwifi-mvm-firmware just nano podman rclone rsync-daemon samba vim wget xdg-dbus-proxy xdg-user-dirs)
rpm-ostree install "${INCLUDED_PACKAGES[@]}"

# Configure samba
setsebool -P samba_export_all_rw 1
