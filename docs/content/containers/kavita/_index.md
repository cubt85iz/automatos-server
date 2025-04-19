---
title: 'Kavita'
comments: false
date: 2025-04-15T14:13:24-04:00
draft: true
weight: 140
---
![Kavita](./kavita.webp)

## Configuration

### Image

```json {filename=".config/my-server-build"}
{
  "containers": [
    "kavita"
  ]
}
```

### Service

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

```systemd {filename="/etc/containers/systemd/kavita.container.d/01-variables.conf"}
[Container]
Environment=TZ=Etc/Utc

[Service]
Environment=CONTAINER_PATH=/path/to/kavita/volumes
Environment=WEB_PORT=5000
```

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
