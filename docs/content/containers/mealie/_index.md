---
title: 'Mealie'
comments: false
date: 2025-04-15T14:13:49-04:00
draft: true
weight: 170
---
![Mealie](./mealie.webp)

## Configuration

### Image

```json {filename=".config/my-server-build"}
{
  "containers": [
    "mealie"
  ]
}
```

### Service

```systemd {base_url="https://github.com/cubt85iz/automatos-server/blob/main", filename="/etc/containers/systemd/mealie.container"}
[Unit]
Description=Container service for Mealie
Requires=network-online.target nss-lookup.target
After=network-online.target nss-lookup.target

[Container]
ContainerName=%p
Image=docker.io/hkotel/%p:latest
Volume=${CONTAINER_PATH}/data:/app/data:Z
PublishPort=${WEB_PORT}:9000
AutoUpdate=registry

[Service]
ExecCondition=/usr/bin/test -d "${CONTAINER_PATH}/data"
Restart=on-failure

[Install]
WantedBy=default.target
```

### Customizations

```systemd {filename="/etc/containers/systemd/mealie.container.d/01-variables.conf"}
[Container]
Environment=PGID=1000
Environment=PUID=1000
Environment=TZ=Etc/Utc

[Service]
Environment=CONTAINER_PATH=/path/to/mealie/volumes
Environment=WEB_PORT=9000
```

## References

- [{{< icon "globe" >}} Website](https://mealie.io/)
- [{{< icon "document-text" >}} Container Installation Instructions](https://docs.mealie.io/documentation/getting-started/installation/installation-checklist/)
- [{{< icon "github" >}} Source Code](https://github.com/mealie-recipes/mealie)
- [{{< icon "document-text" >}} podman-systemd.unit manpage](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html)
