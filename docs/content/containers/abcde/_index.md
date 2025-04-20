---
title: 'Abcde'
comments: false
date: 2025-04-19T10:11:29-04:00
draft: false
weight: 10
---
{{< icon "github" >}} [cubt85iz/abcde-container](https://github.com/cubt85iz/abcde-container)

`abcde` is rips tracks from audio CDs and converts them to various audio formats. automatos-server includes a systemd template that can be used to simultaneously rip audio CDs from multiple devices.

## Configuration

### Image

To use the abcde template, it needs to be included in your generated image. Update your build configuration to include it.

```json {filename=".config/my-server-build"}
{
  "containers": [
    "abcde@"
  ]
}
```

### Service

To use this systemd template, you must provide an optical disk drive device (ex. `/dev/sr0`). This will create a container service for `abcde` that rips the contents of an audio CD inserted into the device.

```systemd {base_url="https://github.com/cubt85iz/automatos-server/blob/main", filename="/etc/containers/systemd/abcde@.container"}
[Unit]
Description=Container for processing audio CDs using abcde

[Container]
ContainerName=%p
Image=ghcr.io/cubt85iz/abcde-container:latest
AddDevice=%I:/dev/cdrom
AutoUpdate=registry

[Service]
ExecStopPost=eject %I
```

### Customizations

The systemd container unit provided above configures most of the properties for the container service, but it does not include volumes for `/etc/abcde.conf` and `/output`. Use a systemd drop-in file to specify these.

```systemd {filename="/etc/containers/systemd/abcde@dev-sr0.container.d/01-volumes.conf"}
[Container]
Volume=/path/to/abcde.conf:/etc/abcde.conf:Z
Volume=/path/to/output:/output:Z
```

#### Device Rules

To automatically rip inserted discs, a udev rule for each optical drive must be created.

```udev {filename="/etc/udev/rules.d/90-abcde.rules"}
SUBSYSTEM=="block", KERNEL=="sr0", ENV{ID_CDROM_MEDIA_CD}=="1", PROGRAM="/usr/bin/systemd-escape --template=abcde@.service $env{DEVNAME}", ENV{SYSTEMD_USER_WANTS}+="%c"
```

Execute `udevadm control --reload-rules` to reload the udev rules.

#### SELinux

Containers must have permission to use devices to access optical drives. Execute `sudo setsebool -P container_use_devices 1` to allow this. Additionally, the SELinux context for the `/etc/abcde.conf` file may need to be set to `system_u:object_r:container_file_t:s0` for the container to be able to access it.

## References

- [{{< icon "globe" >}} Man page](https://linux.die.net/man/1/abcde)
- [{{< icon "document-text" >}} Container Installation Instructions](https://github.com/cubt85iz/abcde-container/tree/main/README.md)
- [{{< icon "github" >}} Source Code](https://github.com/cubt85iz/abcde-container)
- [{{< icon "document-text" >}} podman-systemd.unit manpage](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html)