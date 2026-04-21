---
title: 'RomM'
comments: false
date: 2025-04-17T00:21:02-04:00
draft: false
weight: 290
---
![RomM](./romm.webp)

RomM (Rom Management) is a lightweight, self-hosted tool for organizing, serving, and managing ROM collections. It provides a simple web UI for browsing your collection, metadata management, and optional integration with emulators and front-ends.

## Image / Container files

The image provides *.container unit files under `/opt/containers`. To enable RomM, create a symlink from the appropriate systemd unit location to /opt/containers/romm.container in your Butane configuration.

Per-user unit:

```yaml
variant: fcos
version: 1.5.0
storage:
  links:
    - path: /var/home/romm/.config/containers/systemd/romm.container
      target: /opt/containers/romm.container
```

System-wide unit:

```yaml
variant: fcos
version: 1.5.0
storage:
  links:
    - path: /etc/containers/systemd/romm.container
      target: /opt/containers/romm.container
systemd:
  units:
    - name: romm.container
      enabled: true
```

Ensure the symlink target exists and contains the expected Container and Service sections before enabling the unit.

### Service

Automatos Server runs RomM as a systemd container unit using Quadlet. The example below uses the linuxserver image:

```systemd {base_url="https://github.com/cubt85iz/automatos-server/blob/main", filename="/opt/containers/romm.container"}
[Unit]
Description=Container service for RomM
Requires=network-online.target nss-lookup.target
After=network-online.target nss-lookup.target

[Container]
ContainerName=%p
Image=docker.io/linuxserver/romm:latest
Volume=${CONTAINER_PATH}/romm/config:/config:Z
Volume=${CONTAINER_PATH}/romm/roms:/data/roms:Z
PublishPort=${WEB_PORT}:8080
AutoUpdate=registry

[Service]
EnvironmentFile=/etc/environment
ExecCondition=/usr/bin/test -d "${CONTAINER_PATH}/romm/config"
ExecCondition=/usr/bin/test -d "${CONTAINER_PATH}/romm/roms"
Restart=on-failure

[Install]
WantedBy=default.target
```

Notes:

- The Image field is set to linuxserver/romm:latest; replace the tag with a specific version if desired.
- Adjust PublishPort if the image uses a different internal port.

### Customizations

Use Quadlet drop-in files to define environment variables, extra mounts, device passthrough, or port changes.

Example: define paths and port:

```systemd {filename="/opt/containers/romm.container.d/01-variables.conf"}
[Container]
Environment=ROMM_GID=1000
Environment=ROMM_UID=1000

[Service]
Environment=CONTAINER_PATH=/var/lib/containers
Environment=WEB_PORT=8080
```

Example: add ROM library volume and additional permissions:

```systemd {filename="/opt/containers/romm.container.d/02-volumes.conf"}
[Container]
Volume=/mnt/media/roms:/data/roms:z,rw,rslave,rbind
Volume=/var/lib/romm/thumbnails:/config/thumbnails:z,rw
```

If you integrate RomM with emulators or front-ends on the host, you may need to:

- Ensure file permissions (UID:GID) match the emulator user.
- Mount ROM directories to both RomM and the emulator.
- Configure RomM export options (SMB/NFS) if network clients need direct access.

## References

- [{{< icon "globe" >}} Website](https://romm.app/)
