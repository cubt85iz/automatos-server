---
title: 'Homer'
comments: false
date: 2025-04-19T10:12:43-04:00
draft: false
weight: 110
---
![Homer](./homer.webp)

Homer is a static homepage for listing services/projects available in a homelab.

## Configuration

### Image

To use homer, it needs to be included in your generated image. Update your build configuration to include it.

```json {filename=".config/my-server-build"}
{
  "containers": [
    "homer"
  ]
}
```

### Service

A systemd container unit for homer has been included in `automatos-server`. This container unit file is functional as-is, but users can extend it to incorporate additional customizations using drop-ins.

```systemd {base_url="https://github.com/cubt85iz/automatos-server", filename="/etc/containers/systemd/homer.container"}
[Unit]
Description=Container service for Homer
Requires=network-online.target nss-lookup.target
After=network-online.target nss-lookup.target

[Container]
ContainerName=%p
Image=docker.io/b4bz/homer:latest
Volume=${CONTAINER_PATH}/assets:/www/assets:Z
PublishPort=${WEB_PORT}:8080
AutoUpdate=registry

[Service]
ExecCondition=/usr/bin/test -d "${CONTAINER_PATH}/assets"
Restart=on-failure

[Install]
WantedBy=default.target
```

## References

- {{< icon "github" >}} [Source Code](https://github.com/bastienwirtz/homer)
- {{< icon "document-text" >}} [Documentation](https://github.com/bastienwirtz/homer/blob/main/README.md)
- {{< icon "document-text" >}} [podman-systemd.unit manpage](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html)
