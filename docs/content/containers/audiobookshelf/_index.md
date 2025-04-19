---
title: 'Audiobookshelf'
comments: false
date: 2025-04-15T10:34:59-04:00
draft: true
weight: 30
---
![Audiobookshelf](./audiobookshelf.webp)

Audiobookshelf is an open-source, self-hosted audiobook and podcast server.

## Configuration

### Image

To use audiobookshelf, it needs to be included in your generated image. Update your build configuration to include it.

```json {filename=".config/my-server-build"}
{
  "containers": [
    "audiobookshelf"
  ]
}
```

### Service

Automatos Server uses Quadlet to run the audiobookshelf container as a systemd service. When encountering Container units, systemd generates a service unit file for it. This allows users to manage the container lifecycle with the usual systemd commands.

```systemd {base_url="https://github.com/cubt85iz/automatos-server/blob/main", filename="/etc/containers/systemd/audiobookshelf.container"}
[Unit]
Description=Container service for Audiobookshelf
Requires=network-online.target nss-lookup.target
After=network-online.target nss-lookup.target

[Container]
ContainerName=%p
Image=docker.io/advplyr/audiobookshelf:latest
Volume=${CONTAINER_PATH}/config:/config:Z
Volume=${CONTAINER_PATH}/metadata:/metadata:Z
PublishPort=${WEB_PORT}:80
AutoUpdate=registry

[Service]
EnvironmentFile=/etc/environment
ExecCondition=/usr/bin/test -d "${CONTAINER_PATH}/config"
ExecCondition=/usr/bin/test -d "${CONTAINER_PATH}/metadata"
Restart=on-failure

[Install]
WantedBy=default.target
```

### Customizations

You can utilize drop-ins to customize the audiobookshelf container. The variables `CONTAINER_PATH` and `WEB_PORT` referenced above are variables that are expected to be defined in the drop-in. Additional variables, devices, volumes, etc. can be specified by providing additional drop-ins.

```systemd {filename="/etc/containers/systemd/audiobookshelf.container.d/01-variables.conf"}
[Container]
Environment=AUDIOBOOKSHELF_GID=1000
Environment=AUDIOBOOKSHELF_UID=1000

[Service]
Environment=CONTAINER_PATH=/var/path/to/path/for/audiobookshelf/files
Environment=WEB_PORT=80
```

Audiobookshelf has the environment variables `AUDIOBOOKSHELF_GID` and `AUDIOBOOKSHELF_UID` for specifying the group and user identifiers used for the container. The drop-in shown above demonstrates how these variables can be defined. Special care must be taken to define the variables in the correct area. Rule of thumb is that if they're used by the container then they should be defined in the `Container` section. If they're defined just for the Container unit, then they belong in the `Service` section.

```systemd {filename="/etc/containers/systemd/audiobookshelf.container.d/02-volumes.conf"}
[Container]
Volume=/var/path/to/audiobooks:/audiobooks:z,rw,rslave,rbind
```

This drop-in demonstrates how you can specify a volume for audiobookshelf that specifies the location of the audiobooks.

> [!TIP]
> The values shown above are notional. Customize these values to suit your needs.

## References

- [{{< icon "globe" >}} Website](https://audiobookshelf.org)
- [{{< icon "document-text" >}} Container Installation Instructions](https://www.audiobookshelf.org/docs#docker-compose-install)
- [{{< icon "github" >}} Source Code](https://github.com/advplyr/audiobookshelf)
- [{{< icon "document-text" >}} podman-systemd.unit manpage](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html)
