# CSS Server
## Overview
Dockerfile — Uses debian:bookworm-slim, installs SteamCMD as an unprivileged steam user, downloads the CS:S dedicated server (app 232330), runs the plugin install script, and copies in server.cfg. Exposes ports 27015 (TCP+UDP) and 27020 (UDP).

install_plugins.sh — Downloads and extracts MetaMod:Source and SourceMod from alliedmods.net into cstrike/addons/, writes the metamod.vdf loader file, and verifies both directories exist. Version numbers are pinned at the top of the script — bump them when new builds release.

docker-compose.yml — Builds from the Dockerfile, maps the standard Source server ports, and mounts a named volume for persistent server data.

server.cfg — Minimal starting config. Change rcon_password before running.

## Usage
Open the required server ports
```
  sudo ufw allow 27015/tcp
  sudo ufw allow 27015/udp
  sudo ufw allow 27020/udp
```

Build and start:
```docker compose up -d --build```

## Adding plugins
If you want to add custom SourceMod plugins, drop .smx files into cstrike/addons/sourcemod/plugins/ (persisted via the volume).
