---
title: 'Dotfiles'
comments: false
date: 2025-04-15T15:54:03-04:00
draft: true
weight: 20
---
{{< icon "github" >}} [cubt85iz/automatos-server-dotfiles](https://github.com/cubt85iz/automatos-server-dotfiles)

The `automatos-server-dotfiles` repository contains a collection of dotfiles that can be used to perform common server tasks, such as showing/following logs, listing NFS exports, checking ZFS pools, and displaying networking details.

```bash
❯ just get-pool-health tank
ONLINE
```

A complete list of available recipes can be shown by cloning `automatos-server-dotfiles` repository and executing `just -l`. Additional information about a recipe can be shown by executing `just --show <recipe>`.

## Additional Recipes

Feel free to submit a PR with bugfixes or additional recipes, but they must adhere to some guidelines.

- All recipes should have descriptions.
- All recipes should belong to one or more groups.
- All recipe names should begin with an action (ex. get,generate, show, etc.)
- All recipes using shebangs or scripts should include `set -euo pipefail`.
