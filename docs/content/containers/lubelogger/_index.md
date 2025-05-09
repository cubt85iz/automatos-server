---
title: 'Lubelogger'
comments: false
date: 2025-04-15T14:13:41-04:00
draft: false
weight: 160
---
![LubeLogger](./lubelogger.webp)

LubeLogger is a self-hosted vehicle maintenance tracker.

## Configuration

### Image

To use LubeLogger, it needs to be included in your generated image. Update your build configuration to include it.

```json {filename=".config/my-server-build"}
{
  "containers": [
    "lubelogger"
  ]
}
```

### Service

A systemd container unit for LubeLogger has been included in `automatos-server`. This container unit file serves as a baseline and requires additional customizations from the user to run LubeLogger successfully.

A systemd container unit for LubeLogger has been included in `automatos-server`. This container unit file serves as a baseline and requires additional customizations from the user to run LubeLogger successfully.

```systemd {base_url="https://github.com/cubt85iz/automatos-server/blob/main", filename="/etc/containers/systemd/lubelogger.container"}
[Unit]
Description=Container service for LubeLogger
Requires=network-online.target nss-lookup.target
After=network-online.target nss-lookup.target

[Container]
ContainerName=%p
Image=ghcr.io/hargata/lubelogger:latest
Volume=${CONTAINER_PATH}/config:/App/config:Z
Volume=${CONTAINER_PATH}/data:/App/data:Z
Volume=${CONTAINER_PATH}/documents:/App/documents:Z
Volume=${CONTAINER_PATH}/images:/App/images:Z
Volume=${CONTAINER_PATH}/temp:/App/temp:Z
Volume=${CONTAINER_PATH}/log:/App/log:Z
Volume=${CONTAINER_PATH}/keys:/root/.aspnet/DataProtection-Keys:Z
PublishPort=${WEB_PORT}:8080
AutoUpdate=registry

[Service]
ExecCondition=/usr/bin/test -d "${CONTAINER_PATH}/config"
ExecCondition=/usr/bin/test -d "${CONTAINER_PATH}/data"
ExecCondition=/usr/bin/test -d "${CONTAINER_PATH}/documents"
ExecCondition=/usr/bin/test -d "${CONTAINER_PATH}/images"
ExecCondition=/usr/bin/test -d "${CONTAINER_PATH}/temp"
ExecCondition=/usr/bin/test -d "${CONTAINER_PATH}/log"
ExecCondition=/usr/bin/test -d "${CONTAINER_PATH}/keys"
Restart=on-failure

[Install]
WantedBy=default.target
```

### Customizations

#### Environment Variables

The following environment variables are used to configure the LubeLogger container. The values provided are notional. Customize these values to suit your needs.

```systemd {filename="/etc/containers/systemd/lubelogger.container.d/01-variables.conf"}
[Container]
Environment=LC_ALL=en_US.UTF-8
Environment=LANG=en_US.UTF-8
Environment=TZ=Etc/Utc

[Service]
Environment=CONTAINER_PATH=/path/to/lubelogger/volumes
Environment=WEB_PORT=8080
```

## References

- [{{< icon "globe" >}} Website](https://lubelogger.com/)
- [{{< icon "document-text" >}} Container Installation Instructions](https://docs.lubelogger.com/Installation/Getting%20Started)
- [{{< icon "github" >}} Source Code](https://github.com/hargata/lubelog)
- [{{< icon "document-text" >}} podman-systemd.unit manpage](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html)
