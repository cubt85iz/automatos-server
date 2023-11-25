# OSN (OS for NAS)

Fedora CoreOS image, based on [ucore](https://github.com/ublue-os/ucore.git), with support for ZFS and various containerized services.

## Customization

Clone the repo and create a DEPLOY_SUITE to deploy your own custom combination of services. Use the [osn-ignition](https://github.com/cubt85iz/osn-ignition.git) project for secrets management.

## Installation

1. Clone [osn-ignition](https://github.com/cubt85iz/osn-ignition.git) repository and follow the instructions there to install Fedora CoreOS.
1. Execute the following command to rebase to the unsigned version of this image: `sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/cubt85iz/osn:latest`. NOTE: Replace `osn:latest` with the image name and tag you wish to target.
1. Execute the following command to reboot to the new image: `sudo systemctl reboot`.
1. Execute the following command to rebase to the signed image: `sudo rpm-ostree rebase ostree-image-signed:docker://ghcr.io/cubt85iz/osn:latest`. NOTE: Replace `osn:latest` with the image name and tag you wish to target.
1. Execute the following command to reboot to the new image: `sudo systemctl reboot`
