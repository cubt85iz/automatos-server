#!/bin/bash

set -ouex pipefail

# Define deployment suites
if [ -n "$DEPLOY_SUITE" ]; then
  if [ "$DEPLOY_SUITE" == "all" ]; then
    # Include everything
    INCLUDE_AUDIOBOOKSHELF=y
    INCLUDE_EMBY=y
    INCLUDE_GOTIFY=y
    INCLUDE_IMMICH=y
    INCLUDE_MEALIE=y
    INCLUDE_NEXTCLOUD=y
    INCLUDE_PLEX=y
    INCLUDE_PMM=y
    INCLUDE_SYNCTHING=y
    INCLUDE_UNIFI=y
    INCLUDE_YTSUBS=y
  elif [ "$DEPLOY_SUITE" == "nnk" ]; then
    INCLUDE_SYNCTHING=y
  elif [ "$DEPLOY_SUITE" == "pow" ]; then
    INCLUDE_PLEX=y
  else
    echo "ERROR: Deployment suite not recognized ($DEPLOY_SUITE)."
    exit 1
  fi
else
  echo "ERROR: Deployment suite not provided."
  exit 1
fi

# Remove quadlet containers & networks
pushd /home/core/.config/containers/systemd/ &> /dev/null
if [ -z "${INCLUDE_AUDIOBOOKSHELF-}" ]; then
  rm audiobookshelf.container
fi
if [ -z "${INCLUDE_EMBY-}" ]; then
  rm embyserver.container
fi
if [ -z "${INCLUDE_GOTIFY-}" ]; then
  rm gotify.container
fi
if [ -z "${INCLUDE_IMMICH-}" ]; then
  rm immich*.container
fi
if [ -z "${INCLUDE_MEALIE-}" ]; then
  rm mealie.container
fi
if [ -z "${INCLUDE_NEXTCLOUD-}" ]; then
  rm nextcloud*.container
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

INCLUDED_PACKAGES=(borgbackup curl dbus-tools firewalld iwlegacy-firmware iwlwifi-dvm-firmware iwlwifi-mvm-firmware just nano podman rclone samba vim wget xdg-dbus-proxy xdg-user-dirs)
rpm-ostree install "${INCLUDED_PACKAGES[@]}"

# Configure samba
setsebool -P samba_export_all_rw 1
