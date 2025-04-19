---
title: 'Config'
comments: false
date: 2025-04-15T15:53:56-04:00
draft: true
weight: 10
---
{{< icon "github" >}} [cubt85iz/automatos-server-config](https://github.com/cubt85iz/automatos-server-config)

Automatos Server Config allows you to create and manage your customizations and secrets for Fedora CoreOS images. Automatos Server Config renders the Butane configurations specified in the `config` folder to create one or more Ignition files.

> [!NOTE]
> More information about the Butane specification can be found [here](https://coreos.github.io/butane/config-fcos-v1_6/).

## Usage

To begin, create a new Butane file in the `config` folder for the server you will be provisioning.

```yaml {filename="config/my-server.bu"}
---
variant: fcos
version: 1.6.0

ignition:
  config:
    merge: []

files:
  - path: /etc/hostname
    overwrite: true
    contents:
      inline: my-server.my-domain.com
    user:
      name: root
    group:
      name: root
    mode: 0644

passwd:
  users:
    - name: core
      password_hash: <my-password-hash>
      ssh_authorized_keys:
        - <my-ssh-public-key>
```

Once you have created your Butane file, you can execute the following command to build and serve the Ignition file: `just lint build validate serve`.

To extend your configuration, create a new folder in the `config` folder for each server. Create new Butane files in these folders and update the `ignition.config.merge` list to include the path to your generated ignition file.

> [!IMPORTANT]
> The paths specified to this list must be relative to the root of the project and end with the `.ign` extension. For example, if you have a Butane file named `audiobookshelf.bu` in `config/my-server`, then you would add `config/my-server/audiobookshelf.ign` to the `ignition.config.merge` list.
