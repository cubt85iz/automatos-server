---
title: 'Jellyfin'
comments: false
date: 2025-04-15T14:13:16-04:00
draft: true
weight: 130
---
![Jellyfin](./jellyfin.webp)

## Configuration

### Image

```json {filename=".config/my-server-build"}
{
  "containers": [
    "jellyfin"
  ]
}
```

### Service

```systemd {base_url="https://github.com/cubt85iz/automatos-server/blob/main", filename="/etc/containers/systemd/jellyfin.container"}
[Unit]
Description=Container service for Jellyfin
Requires=network-online.target nss-lookup.target jellyfin-network.service
After=network-online.target nss-lookup.target jellyfin-network.service

[Container]
ContainerName=%p
Image=docker.io/jellyfin/%p:latest
AddDevice=/dev/dri
Volume=${CONTAINER_PATH}/config:/config:Z
Volume=${CONTAINER_PATH}/cache:/cache:Z
PublishPort=${WEB_PORT}:8096
Tmpfs=/transcode
User=${UID}
Group=${GID}
Network=jellyfin-network
AutoUpdate=registry

[Service]
EnvironmentFile=/etc/environment
ExecCondition=/usr/bin/test -d "${CONTAINER_PATH}/config"
ExecCondition=/usr/bin/test -d "${CONTAINER_PATH}/cache"
Restart=on-failure

[Install]
WantedBy=default.target
```

> [!IMPORTANT]
> This container definition is still a little too opinionated. It assumes the user will have a device for hardware-accelerated encoding. It also makes assumptions about networking. In the future, these parameters may be removed and demonstrated below as customizations.

```systemd {base_url="https://github.com/cubt85iz/automatos-server/blob/main", filename="/etc/containers/systemd/jellyfin.network"}
[Network]
NetworkName=%N
Subnet=172.16.203.0/24
IPv6=true
```

### Customizations

```systemd {filename="/etc/containers/systemd/jellyfin.container.d/01-variables.conf"}
[Container]
Environment=GID=1000
Environment=JELLYFIN_PublishedServerUrl=https://proxy.to.jellyfin
Environment=TZ=Etc/Utc
Environment=UID=1000

[Service]
Environment=CONTAINER_PATH=/var/path/to/jellyfin/volumes
Environment=WEB_PORT=8096
```

```systemd {filename="/etc/containers/systemd/jellyfin.container.d/02-volumes.conf"}
[Container]
Volume=/path/to/movies:/media/movies:z,rw,rslave,rbind
Volume=/path/to/tv:/media/tv:z,rw,rslave,rbind
```

## References

- [{{< icon "globe" >}} Website](https://jellyfin.org/)
- [{{< icon "document-text" >}} Container Installation Instructions](https://jellyfin.org/docs/general/installation/container/#podman)
- [{{< icon "github" >}} Source Code](https://github.com/jellyfin/jellyfin)
- [{{< icon "document-text" >}} podman-systemd.unit manpage](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html)
