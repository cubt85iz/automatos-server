---
title: 'Beets'
comments: false
date: 2025-04-15T14:10:32-04:00
draft: true
weight: 40
---
![Beets](./beets.webp)

## Configuration

### Image

```json {filename=".config/my-server-build"}
{
  "containers": [
    "beets"
  ]
}
```

### Service

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

```systemd {filename="/etc/containers/systemd/beets.container.d/01-variables.conf"}
[Container]
Environment=PGID=1000
Environment=PUID=1000
Environment=TZ=Etc/Utc

[Service]
Environment=CONTAINER_PATH=/var/path/for/beets/volumes
```

## References

- [{{< icon "globe" >}} Website](https://beets.io/)
- [{{< icon "document-text" >}} Container Installation Instructions](https://docs.linuxserver.io/images/docker-beets/)
- [{{< icon "github" >}} Source Code](https://github.com/beetbox/beets)
- [{{< icon "document-text" >}} podman-systemd.unit manpage](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html)
