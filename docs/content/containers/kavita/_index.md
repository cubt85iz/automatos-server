---
title: 'Kavita'
comments: false
date: 2025-04-15T14:13:24-04:00
draft: false
weight: 140
---
![Kavita](./kavita.webp)

Kavita is a self-hosted digital library for books, comics, and manga.

## Configuration

### Image

To use kavita, it needs to be included in your generated image. Upudate your build configuration to include it.

```json {filename=".config/my-server-build"}
{
  "containers": [
    "kavita"
  ]
}
```

### Service

A systemd container unit for kavita has been included in `automatos-server`. This container unit file serves as a baseline and requires additional customizations from the user to run kavita successfully.

```systemd {base_url="https://github.com/cubt85iz/automatos-server/blob/main", filename="/etc/containers/systemd/kavita.container"}
[Unit]
Description=Container service for Kavita
Requires=network-online.target nss-lookup.target zfs.target
After=network-online.target nss-lookup.target zfs.target

[Container]
ContainerName=%p
Image=ghcr.io/kareadita/kavita:latest
Volume=${CONTAINER_PATH}/config:/kavita/config:Z
PublishPort=${WEB_PORT}:5000
Environment=DOTNET_GLOBALIZATION_INVARIANT=true
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

The following environment variables are used to configure the kavita container. The values provided are notional. Customeize these values to suit your needs.

```systemd {filename="/etc/containers/systemd/kavita.container.d/01-variables.conf"}
[Container]
Environment=TZ=Etc/Utc

[Service]
Environment=CONTAINER_PATH=/path/to/kavita/volumes
Environment=WEB_PORT=5000
```

#### Volumes

The following volumes are utilized by kavita. They need to be defined before kavita will execute successfully.

```systemd {filename="/etc/containers/systemd/kavita.container.d/02-volumes.conf"}
[Container]
Volume=/path/to/literature:/literature:z,rw,rslave,rbind

[Service]
ExecCondition=/usr/bin/test -d "/path/to/literature"
```

## References

- [{{< icon "globe" >}} Website](https://www.kavitareader.com/)
- [{{< icon "document-text" >}} Container Installation Instructions](https://wiki.kavitareader.com/installation/docker/dockerhub/)
- [{{< icon "github" >}} Source Code](https://github.com/Kareadita/Kavita)
- [{{< icon "document-text" >}} podman-systemd.unit manpage](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html)
