# CSS Server

Dockerized Counter-Strike: Source dedicated server with MetaMod:Source and SourceMod. Supports running multiple servers with different mods via Docker Compose.

## Project Structure

```
├── Dockerfile              # Runtime image (debian + i386 libs, no game data)
├── docker-compose.yml      # Defines each server as a service
├── setup.sh                # Installs game + mods into instances/<server>/
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

## Usage

Open the required server ports (add more ports as you add servers):
```
sudo ufw allow 27015/tcp
sudo ufw allow 27015/udp
sudo ufw allow 27020/udp
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

Restart the server after adding new maps or plugins:
```
docker compose restart casual
```

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
       - ./instances/surf/sdk32:/root/.steam/sdk32:ro
     restart: unless-stopped
     stdin_open: true
     tty: true
     command: ["-game", "cstrike", "-console", "-tickrate", "102", "-port", "27016", "+maxplayers", "32", "+map", "surf_mesa"]
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
