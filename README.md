# automatos-server

Fedora CoreOS image, based on [ucore](https://github.com/ublue-os/ucore.git), with support for ZFS and various containerized services.

## Customization

Clone the repo and create a configuration file in the .config folder. In the configuration file, specify your custom configuration. Use the [automatos-server-config](https://github.com/cubt85iz/automatos-server-config.git) project for secrets management.

## Installation

1. Clone [automatos-server-config](https://github.com/cubt85iz/automatos-server-config.git) repository and follow the instructions there to install Fedora CoreOS.
1. Execute the following command to rebase to Universal Blue's fedora-coreos base image: `sudo rpm-ostree rebase --reboot --bypass-driver ostree-unverified-registry:ghcr.io/ublue-os/fedora-coreos:stable-zfs`.
1. Log in and import ZFS pools (ex. `zfs import <pool-name>`).
1. Execute the following command to rebase to automatos-server: `sudo rpm-ostree rebase --reboot ostree-unverified-registry:ghcr.io/cubt85iz/automatos-server:latest`. NOTE: Replace `automatos-server:latest` with the image name and tag you wish to target.

## Experimental

The following features are experimental/untested:

* MinIO

## Implementation

Containers are defined using quadlets and placed in the /etc/containers/systemd folder. Each of these quadlets reference environment files stored in /etc/containers/config. These environment files contain the secrets for each container. The /etc/environment file is used to store global variables for containers (ex. SHARED_VOLUME_PATH). The values for these variables are shared amongst all containers and this limits how many times they must be defined.
