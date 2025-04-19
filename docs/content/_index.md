---
title: 'Automatos Server'
breadcrumbs: false
cascade:
  type: docs
comments: false
date: 2025-04-15T12:27:06-04:00
draft: true
---
{{< icon "github" >}} [cubt85iz/automatos-server](https://github.com/cubt85iz/automatos-server)

Automatos Server allows you to create and manage your own Fedora CoreOS images for a home server. It is designed to be a flexible way of building customizable images that can be used in a variety of ways. It extends the functionality provided by the [ucore](https://github.com/ublue-os/ucore) fedora-coreos images to include containers and utilities for server management.

Automatos Server reads the specified configuration file during the image build process. It parses the configuration file to determine the packages, containers, repositories, and other components to include in the final image. To specify a configuration file, you can define the `CONFIG` variable when building the image.

Automatos Server reviews the requirements for each container and resolves any dependencies. After assembling a complete list of containers to install, it removes any files associated with containers that were not specified in the configuration file. This can include networks, timers, and services that may be associated with a container.

## Development

> [!IMPORTANT]
> Secrets and customizations for Fedora CoreOS are managed using Ignition files. The [automatos-server-config](https://github.com/cubt85iz/automatos-server-config) project was created to make that process a little easier. The `redesign_bu` branch contains tooling to generate an Ignition file from multiple butane configurations.

1. To create a custom image, you must first fork this repository.
1. After forking the repository, you can create your own configuration and place it in the `.config` folder.
1. Next, you'll need to enable the `build` workflow for the container file.

> [!TIP]
> You will have to generate your own cosign keys and store the private key as a repository secret before you can build the image. The `SIGNING_SECRET` variable should containthe contents of the private key.

4. Execute the build action to build and publish the container image as a Github package. {{< mdl-disable "<!-- markdownlint-disable MD029 -->" >}}
4. You can now use the `rpm-ostree rebase` command to switch to the new image.

## Installation

1. Clone the [automatos-server-config](https://github.com/cubt85iz/automatos-server-config) repository.

> [!TIP]
> Use the `redesign_bu` branch. This branch adds support for merging several configurations to create a single Ignition file. It will supersede the existing `main` branch at some point in the near future.

2. Using the instructions found in the automatos-server-config repository, create your new configuration and generate your Ignition file.
2. Serve the Ignition file and ensure it is accessible from a web browser.
2. Create a USB drive for installing Fedora CoreOS on an x86_64 machine.
2. Boot into the Live Fedora CoreOS environment.
2. Identify the disk drive that will be used for the Fedora CoreOS installation.
2. Execute `coreos-installer install --ignition-url http://url-to-your-ignition-file --insecure-ignition /dev/disk-device` to install Fedora CoreOS.
2. Reboot into the new system.
2. Execute the following command to rebase to the automatos-server-base image: `sudo rpm-ostree rebase --reboot --bypass-driver ostree-unverified-registry:ghcr.io/cubt85iz/automatos-server-base:latest`.

> [!NOTE]
> The `automatos-server-base` image includes ZFS and other common software packages. It is a useful intermediate step that can allow you to import ZFS pools before deploying an image that contains the containers. It can also be used to configure packages installed on the host (ex. samba).

10. Execute the following command to rebase to your automatos-server image: `sudo rpm-ostree rebase --reboot ostree-unverified-registry:ghcr.io/<username>/automatos-server-<package>:latest`.
