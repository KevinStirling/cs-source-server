# CSS Server

Dockerized Counter-Strike: Source dedicated server with MetaMod:Source and SourceMod. Supports running multiple servers with different mods via Docker Compose.

## Project Structure

```
├── Dockerfile              # Runtime image (debian + i386 libs, no game data)
├── docker-compose.yml      # Defines each server as a service + FastDL nginx
├── setup.sh                # Installs game + mods into instances/<server>/
├── compress_maps.sh        # Bzip2-compresses custom maps for FastDL
├── fastdl.conf             # Nginx config for FastDL
├── install_base.sh         # Installs MetaMod:Source + SourceMod (shared by all servers)
├── servers/
│   └── casual/
│       ├── install_mods.sh # Server-specific plugin installation
│       └── server.cfg      # Server-specific config
└── instances/              # Created by setup.sh, mounted by Docker (gitignored)
    └── casual/
        ├── css/            # Full game installation
        └── sdk32/          # steamclient.so for runtime
```

## Prerequisites

Install the 32-bit libraries required by SteamCMD:
```
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install lib32gcc-s1 lib32stdc++6 libz1:i386 bzip2
```

## Usage

Open the required server ports (add more ports as you add servers):
```
sudo ufw allow 27015/tcp
sudo ufw allow 27015/udp
sudo ufw allow 27020/tcp
```

Create a `.env` file with your Steam Game Server Login Token ([create one here](https://steamcommunity.com/dev/managegameservers)) and FastDL URL:
```
STEAM_LOGIN_TOKEN=your_token_here
FASTDL_URL=http://your-server-ip:27020
```

Install the game and mods for a server:
```
./setup.sh casual
```

Build and start:
```
docker compose up -d --build
```

Start a specific server:
```
docker compose up -d casual
```

View logs:
```
docker compose logs -f casual
```

Access the server console:
```
docker compose attach casual
```

Stop all servers:
```
docker compose down
```

## Adding Custom Content

The game files live on the host under `instances/<server>/css/`. Add content via SFTP or directly:

- **Maps:** `instances/casual/css/cstrike/maps/`
- **Plugins:** `instances/casual/css/cstrike/addons/sourcemod/plugins/`
- **Configs:** `instances/casual/css/cstrike/cfg/`

After adding custom maps, compress them for FastDL:
```
./compress_maps.sh casual
```

Restart the server to pick up changes:
```
docker compose restart casual
```

## FastDL

An nginx container serves custom content to clients on port 27020. Clients connecting to the server will automatically download any custom maps they're missing.

Set the `FASTDL_URL` in your `.env` file to your server's public IP:
```
FASTDL_URL=http://1.2.3.4:27020
```

After adding new custom maps, always run `./compress_maps.sh <server>` to create `.bz2` files for faster client downloads.

## Adding a New Server

1. Create a new directory under `servers/`:
   ```
   mkdir servers/surf
   ```

2. Add an `install_mods.sh` script for any server-specific plugins:
   ```bash
   #!/usr/bin/env bash
   set -euo pipefail

   CSS_DIR="${GAME_DIR:?GAME_DIR must be set}/cstrike"
   # curl -sSL "https://example.com/plugin.smx" \
   #     -o "${CSS_DIR}/addons/sourcemod/plugins/plugin.smx"
   ```

3. Add a `server.cfg` with the server's settings.

4. Run setup:
   ```
   ./setup.sh surf
   ```

5. Add a new service in `docker-compose.yml` with a unique port:
   ```yaml
   surf:
     build: .
     container_name: css-surf
     network_mode: host
     working_dir: /css
     volumes:
       - ./instances/surf/css:/css
       - ./instances/surf/sdk32:/home/steam/.steam/sdk32:ro
     restart: unless-stopped
     stdin_open: true
     tty: true
     env_file: .env
     command: ["-game", "cstrike", "-console", "-tickrate", "102", "-port", "27016", "+maxplayers", "32", "+sv_setsteamaccount", "${STEAM_LOGIN_TOKEN}", "+sv_downloadurl", "${FASTDL_URL}", "+map", "surf_mesa"]
   ```

6. Open the new port in your firewall:
   ```
   sudo ufw allow 27016/tcp
   sudo ufw allow 27016/udp
   ```

## Updating Base Plugins

MetaMod:Source and SourceMod versions are pinned at the top of `install_base.sh`. Bump the version and build numbers there, then re-run setup:
```
./setup.sh casual
```
