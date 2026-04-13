# CSS Server

Dockerized Counter-Strike: Source dedicated server with MetaMod:Source and SourceMod. Supports running multiple servers with different mods via Docker Compose.

## Project Structure

```
├── Dockerfile              # Shared base image, accepts SERVER_DIR build arg
├── docker-compose.yml      # Defines each server as a service
├── install_base.sh         # Installs MetaMod:Source + SourceMod (shared by all servers)
└── servers/
    └── casual/
        ├── install_mods.sh # Calls install_base.sh, then adds server-specific plugins
        └── server.cfg      # Server-specific config
```

## Usage

Open the required server ports (add more ports as you add servers):
```
sudo ufw allow 27015/tcp
sudo ufw allow 27015/udp
sudo ufw allow 27020/udp
```

Build and start:
```
docker compose up -d --build
```

Start a specific server:
```
docker compose up -d --build casual
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

## Adding a New Server

1. Create a new directory under `servers/`:
   ```
   mkdir servers/surf
   ```

2. Add an `install_mods.sh` script that calls the base installer, then adds any server-specific plugins:
   ```bash
   #!/usr/bin/env bash
   set -euo pipefail
   /home/steam/install_base.sh

   CSS_DIR="/home/steam/css/cstrike"
   # curl -sSL "https://example.com/plugin.smx" \
   #     -o "${CSS_DIR}/addons/sourcemod/plugins/plugin.smx"
   ```

3. Add a `server.cfg` with the server's settings.

4. Add a new service in `docker-compose.yml` with a unique host port:
   ```yaml
   surf:
     build:
       context: .
       args:
         SERVER_DIR: servers/surf
     container_name: css-surf
     restart: unless-stopped
     ports:
       - "27016:27015/tcp"
       - "27016:27015/udp"
     stdin_open: true
     tty: true
     volumes:
       - surf-data:/home/steam/css/cstrike
     command: ["-game", "cstrike", "-console", "-tickrate", "102",
               "-port", "27015", "+maxplayers", "32", "+map", "surf_mesa"]
   ```
   Don't forget to add the volume (`surf-data:`) to the `volumes:` section at the bottom.

5. Open the new port in your firewall:
   ```
   sudo ufw allow 27016/tcp
   sudo ufw allow 27016/udp
   ```

## Updating Base Plugins

MetaMod:Source and SourceMod versions are pinned at the top of `install_base.sh`. Bump the version and build numbers there, then rebuild:
```
docker compose up -d --build
```
