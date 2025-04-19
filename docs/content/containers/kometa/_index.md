---
title: 'Kometa'
comments: false
date: 2025-04-15T14:13:32-04:00
draft: true
weight: 150
---
![Kometa](./kometa.webp)

## Configuration

### Image

```json {filename=".config/my-server-build"}
{
  "containers": [
    "kometa"
  ]
}
```

### Service

```systemd {base_url="https://github.com/cubt85iz/automatos-server/blob/main", filename="/etc/containers/systemd/kometa.container"}
[Unit]
Description=Container service for Kometa
Requires=network-online.target nss-lookup.target zfs.target
After=network-online.target nss-lookup.target zfs.target

[Container]
ContainerName=%p
Image=docker.io/kometateam/kometa:nightly
Volume=${CONTAINER_PATH}/config:/config:Z
Network=plex-network
AutoUpdate=registry

[Service]
ExecCondition=/usr/bin/test -d "${CONTAINER_PATH}/config"
Restart=on-failure
```

### Customizations

```systemd {filename="/etc/containers/systemd/kometa.container.d/01-variables.conf"}
[Container]
Environment=KOMETA_RUN=true
Environment=TZ=Etc/Utc

[Service]
Environment=CONTAINER_PATH=/path/to/kometa/volumes
```

```systemd {filename="/etc/systemd/system/kometa.timer"}
[Unit]
Description=Periodically run Kometa to manage collection in Plex

[Timer]
OnBootSec=15min
OnUnitInactiveSec=2h

[Install]
WantedBy=timers.target
```

> [!NOTE]
> With these customizations, the kometa container will be started 15 minutes after boot and will restart every 2 hours after it has been inactive for that period of time.

## References

- [{{< icon "globe" >}} Website](https://kometa.wiki/)
- [{{< icon "document-text" >}} Container Installation Instructions](https://kometa.wiki/en/latest/kometa/install/walkthroughs/docker/)
- [{{< icon "github" >}} Source Code](https://github.com/Kometa-Team/Kometa)
- [{{< icon "document-text" >}} podman-systemd.unit manpage](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html)
