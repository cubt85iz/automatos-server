# OSN

Fedora CoreOS image, based on [ucore](https://github.com/ublue-os/ucore.git), with support for ZFS and various vontainerized services.

## Installation

1. Clone [osn-ignition](https://github.com/cubt85iz/osn-ignition.git) repository.
1. Create a `secrets.yml` using the provided example.
1. Execute `just serve` to spin up a python web server to host the generated ignition configuration.
1. Load live environment for CoreOS and execute `sudo coreos-installer --insecure-ignition --ignition-url http://<web-server-ip>:8080/.generated/config.ign /dev/nvme0n1`
1. Execute `systemctl reboot` to reboot into Fedora CoreOS.
1. Rebase to repository.
1. Rebase to image.
