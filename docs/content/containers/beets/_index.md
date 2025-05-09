---
title: 'Beets'
comments: false
date: 2025-04-15T14:10:32-04:00
draft: false
weight: 40
---
![Beets](./beets.webp)

Beets is a music library management tool that allows you to organize your music collection.

## Configuration

### Image

To use beets, it needs to be included in your generated image. Update your build configuration to include it.

```json {filename=".config/my-server-build"}
{
  "containers": [
    "beets"
  ]
}
```

### Service

A systemd container unit for beets has been included in `automatos-server`. This container unit file serves as a baseline and requires additional customizations from the user to run beets successfully.

```systemd {base_url="https://github.com/cubt85iz/automatos-server/blob/main", filename="/etc/containers/systemd/beets.container"}
[Unit]
Description=Container service for Beets
Requires=network-online.target nss-lookup.target
After=network-online.target nss-lookup.target

[Container]
ContainerName=%p
Image=lscr.io/linuxserver/beets:latest
Volume=${CONTAINER_PATH}/config:/config:Z
AutoUpdate=registry

[Service]
EnvironmentFile=/etc/environment
ExecCondition=/usr/bin/test -d "${CONTAINER_PATH}/config"
Restart=on-failure

[Install]
WantedBy=default.target
```

### Customizations

#### Environment Variables

The following environment variables are used to configure the beets container. The values provided are notional. Customize these values to suit your needs.

```systemd {filename="/etc/containers/systemd/beets.container.d/01-variables.conf"}
[Container]
Environment=PGID=1000
Environment=PUID=1000
Environment=TZ=Etc/Utc

[Service]
Environment=CONTAINER_PATH=/var/path/for/beets/volumes
```

#### Volumes

The following volumes are utilized by beets. They need to be defined before beets will execute successfully.

```systemd {filename="/etc/containers/systemd/beets.container.d/02-volumes.conf"}
[Container]
Volume=/path/to/staging:/downloads:Z
Volume=/path/to/music:/music:z,rw,rslave,rbind
```

> [!NOTE]
> The options `Z` & `z,rw,rslave,rbind` are for configuring bind propagation for the volume mounts. For more information about bind propagation, review [Configuration bind propagation](https://docs.docker.com/engine/storage/bind-mounts/#configure-bind-propagation) and [Configure the SELinux label](https://docs.docker.com/engine/storage/bind-mounts/#configure-the-selinux-label) in the Docker documentation.

## References

- [{{< icon "globe" >}} Website](https://beets.io/)
- [{{< icon "document-text" >}} Container Installation Instructions](https://docs.linuxserver.io/images/docker-beets/)
- [{{< icon "github" >}} Source Code](https://github.com/beetbox/beets)
- [{{< icon "document-text" >}} podman-systemd.unit manpage](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html)
