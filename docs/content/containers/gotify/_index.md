---
title: 'Gotify'
comments: false
date: 2025-04-15T14:12:46-04:00
draft: true
weight: 90
---
![Gotify](./gotify.webp)

## Configuration

### Image

```json {filename=".config/my-server-build"}
{
  "containers": [
    "gotify"
  ]
}
```

### Service

```systemd {base_url="https://github.com/cubt85iz/automatos-server/blob/main", filename="/etc/containers/systemd/gotify.container"}
[Unit]
Description=Container service for %p
Requires=network-online.target nss-lookup.target
After=network-online.target nss-lookup.target

[Container]
ContainerName=%p
Image=docker.io/gotify/server:latest
Volume=${CONTAINER_PATH}/data:/app/data:Z
PublishPort=${WEB_PORT}:80
AutoUpdate=registry

[Service]
ExecCondition=/usr/bin/test -d "${CONTAINER_PATH}/data"
Restart=on-failure

[Install]
WantedBy=default.target
```

### Customizations

```systemd {filename="/etc/containers/systemd/gotify.container.d/01-variables.conf"}
[Container]
Environment=TZ=Etc/Utc

[Service]
Environment=CONTAINER_PATH=/var/path/to/gotify/volumes
Environment=WEB_PORT=80
```

## References

- [{{< icon "globe" >}} Website](https://gotify.net/)
- [{{< icon "document-text" >}} Container Installation Instructions](https://gotify.net/docs/install#docker)
- [{{< icon "github" >}} Source Code](https://github.com/gotify/server)
- [{{< icon "document-text" >}} podman-systemd.unit manpage](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html)
