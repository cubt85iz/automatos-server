# Containers

To add support for a new service, add a systemd container file and update the `install.sh` shell script to include code to remove the container file when the user has specified they do not wish to include it.

## Supported Containers

### abcde

[abcde-container](https://github.com/cubt85iz/abcde-container) is a container that will automatically rip CDs. To use, create a drop-in for the service to specify the volumes (`/etc/abcde.conf` and `/dev/cdrom`) and `/etc/udev/rules.d/*.rules` file. Click the link for more detailed instructions.

### Actual

[Actual](https://actualbudget.org) is a super fast and privacy-focused app for managing your finances.

### Audiobookshelf

[Audiobookshelf](https://www.audiobookshelf.org/docs) is an open-source self-hosted media server for your audiobooks and podcasts.

### Beets

[Beets](https://beets.io) is the media library management system for obsessive music geeks.

### Caddy Web Server

[Caddy](https://caddyserver.com) is a web server that serves every site with TLS by default, without any configuration or hassle. It can also be configured as a reverse proxy.

### Calibre-Web

[Calibre-Web](https://github.com/janeczku/calibre-web) is a web app that offers a clean and intuitive interface for browsing, reading, and downloading eBooks using a valid Calibre database.

### Code Server

[Code Server](https://github.com/coder/code-server) allows users to run VS Code on any machine anywhere and access it in the browser.

### Donetick

[Donetick](https://donetick.com) is a smart task manager that keeps individuals and families organized with intelligent scheduling and fair task distribution.

### Dynamic DNS Updater

[ddns-updater](https://github.com/cubt85iz/ddns-updater.git) is a container that will update A/AAAA records with WAN IP address.

### Emby

[Emby](https://emby.media) is a media server designed to organize, play, and stream audio and video to a variety of devices.

### Gotify

[Gotify](https://gotify.net) is a free and open source project that lets you control your data and communicate via a REST-API and a web socket.

### Home Assistant

[Home Assistant](https://www.home-assistant.io) is free and open-source software used for home automation. It serves as an integration platform and smart home hub, allowing users to control smart home devices.

### Homer

[Homer](https://github.com/bastienwirtz/homer) is a lightweight and fast dashboard that lets you keep your services on hand with a simple yaml configuration file.

### Immich

[Immich](https://immich.app) helps you browse, search and organize your photos and videos with ease, without sacrificing your privacy.

### Jellyfin

[Jellyfin](https://jellyfin.org) is a free and open-source media server and suite of multimedia applications designed to organize, manage, and share digital media files to networked devices.

### Kavita

[Kavita](https://www.kavitareader.com/) is an open-source, self-hosted digital library management system primarily designed for managing and reading comics, manga, and ebooks.

### Kometa

[Kometa](https://kometa.wiki) (formerly known as Plex Meta Manager) is a powerful tool designed to give you complete control over your media libraries.

### LubeLogger

[LubeLogger](https://lubelogger.com) is a self-hosted, open-source software that lets you manage your vehicle records, fuel economy, taxes, supplies, and reminders.

### Mealie

[Mealie](https://mealie.io) is a web app that lets you manage your recipes, import them from the web, and share them with your family.

### MinIO

[MinIO](https://github.com/minio/minio) is a High Performance Object Storage released under GNU Affero General Public License v3.0.

### Navidrome

[Navidrome](https://www.navidrome.org) is an open source web-based music collection server and streamer.

### Nextcloud

[Nextcloud](https://nextcloud.com) is a self-hosted file storage and sync platform with powerful collaboration capabilities for remote work and data protection.

### Ollama

[Ollama](https://github.com/ollama/ollama) is an application that allows users to run large language models locally, including offline capabilities. It supports both CPU and GPU installations, with specific versions for NVIDIA and AMD graphics cards.

### Opnsense-bkp

[opnsense-bkp](https://github.com/cubt85iz/opnsense-bkp.github) is a container that connects to a specified opnsense router and downloads its configuration.

### Paperless-ngx

[Paperless-ngx](https://docs.paperless-ngx.com/) transforms your physical documents into a searchable online archive that you can keep, well, less paper.

### Photoprism

[PhotoPrism](https://www.photoprism.app) is a self-hosted app that lets you browse, search, and play your photos and videos automatically.

### Pinchflat

[Pinchflat](https://github.com/kieraneglin/pinchflat) downloads YouTube content to disk for media center apps or archiving.

### Plex

[Plex](https://plex.tv) is an ad-supported streaming service that allows users to also stream their personal media collections to their devices.

### ProtonMail Bridge

[Proton Mail Bridge](https://github.com/ProtonMail/proton-bridge) provides local IMAP/SMTP endpoints for a configured Proton Mail account.

### Radicale

[Radicale](https://radicale.org) is a small but powerful CalDAV (calendars, to-do lists) and CardDAV (contacts) server.

### Syncthing

[Syncthing](https://syncthing.net) is a free and open source software that syncs files between your devices in real time, without a central server.

### Tautulli

[Tautulli](https://tautulli.com) is a 3rd party application that you can run alongside your Plex Media Server to monitor activity and track various statistics.

### UniFi

[UniFi Web Controller](https://www.ui.com) allows users to manage UniFi network devices.

### Vikunja

[Vikunja](https://vikunja.io) is the perfect solution for homelab enthusiasts looking for a way to track tasks, set reminders and due dates, categorize tasks into lists, and prioritize projects in your everyday life.
