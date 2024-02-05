# OSN (OS for NAS)

Fedora CoreOS image, based on [ucore](https://github.com/ublue-os/ucore.git), with support for ZFS and various containerized services.

## Customization

Clone the repo and create a DEPLOY_SUITE to deploy your own custom combination of services. Use the [osn-ignition](https://github.com/cubt85iz/osn-ignition.git) project for secrets management.

## Installation

1. Clone [osn-ignition](https://github.com/cubt85iz/osn-ignition.git) repository and follow the instructions there to install Fedora CoreOS.
1. Execute the following command to rebase to Universal Blue's fedora-coreos base image: `sudo rpm-ostree rebase --reboot --bypass-driver ostree-unverified-registry:ghcr.io/ublue-os/fedora-coreos:stable-zfs`.
1. Log in and import ZFS pools (ex. `zfs import <pool-name>`).
1. Execute the following command to rebase to osn: `sudo rpm-ostree rebase --reboot ostree-unverified-registry:ghcr.io/cubt85iz/osn:latest`. NOTE: Replace `osn:latest` with the image name and tag you wish to target.

## Experimental

The following features are experimental/untested:

* Jellyfin
* MinIO
* YTSubs
