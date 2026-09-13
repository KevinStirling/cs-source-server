# CSS Server

Dockerized Counter-Strike: Source dedicated server with MetaMod:Source and SourceMod. Supports running multiple servers with different mods via Docker Compose.

## Project Structure

```
├── Dockerfile              # Runtime image (debian + i386 libs, no game data)
├── docker-compose.yml      # Defines each server as a service + FastDL nginx
├── setup.sh                # Installs game + base mods into instances/<server>/
├── addmap.sh               # Adds a map, compresses it, updates mapcycle
├── compress_maps.sh        # Bzip2-compresses custom maps for FastDL
├── fastdl.conf             # Nginx config for FastDL
├── install_base.sh         # Installs MetaMod:Source + SourceMod (shared by all servers)
└── instances/              # Created by setup.sh, mounted by Docker (gitignored)
    └── classic/
        ├── css/            # Full game installation
        └── sdk32/          # steamclient.so for runtime
```

## Prerequisites

Install the 32-bit libraries required by SteamCMD:
```
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install lib32gcc-s1 lib32stdc++6 libz1:i386 bzip2 unzip curl
```

## Usage

Open the required server ports (add more ports as you add servers):
```
sudo ufw allow 27015/tcp
sudo ufw allow 27015/udp
sudo ufw allow 27020/tcp
```

Create a `.env` file with your Steam Game Server Login Token ([create one here](https://steamcommunity.com/dev/managegameservers)):
```
STEAM_LOGIN_TOKEN=your_token_here
```

Install the game and base mods for a server:
```
./setup.sh classic
```

Build and start:
```
docker compose up -d --build
```

Start a specific server:
```
docker compose up -d classic
```

View logs:
```
docker compose logs -f classic
```

Access the server console:
```
docker compose attach classic
```

Stop all servers:
```
docker compose down
```

## Adding Custom Content

All content such as maps, materials, models, sound are added by moving the file into their respective directory inside instances/{instance}/css/cstrike/. To automatically compress all files that have not yet been compressed, run `compress_files.sh` and point it at the desired instance. This will make the files available to fastdl.

```
./compress_files casual
```

## FastDL

An nginx container serves custom content to clients on port 27020. Clients connecting to the server will automatically download any custom maps they're missing.

Set `sv_downloadurl` in your instance's `server.cfg` to your server's public IP:
```
sv_downloadurl "http://your-server-ip:27020"
```

After adding new custom maps, always run `./compress_maps.sh <server>` to create `.bz2` files for faster client downloads.

## Adding a New Server

1. Run setup to install the game and base mods:
   ```
   ./setup.sh surf
   ```

2. Add a new service in `docker-compose.yml` with a unique port:
   ```yaml
   surf:
     build: .
     container_name: css-surf
     working_dir: /css
     volumes:
       - ./instances/surf/css:/css
       - ./instances/surf/sdk32:/home/steam/.steam/sdk32:ro
     restart: unless-stopped
     stdin_open: true
     tty: true
     env_file: .env
     command: ["-game", "cstrike", "-console", "-tickrate", "102", "-port", "27035", "+maxplayers", "32", "+sv_setsteamaccount", "${STEAM_LOGIN_TOKEN}", "+map", "surf_mesa"]
    ports: 
      - "27035:27035/udp"
      - "27035:27035/tcp"
    networks:
      - default
      - sourcebans_net
   ```

3. Open the new port in your firewall:
   ```
   sudo ufw allow 27035/tcp
   sudo ufw allow 27035/udp
   ```

## Updating Base Plugins

MetaMod:Source and SourceMod versions are pinned at the top of `install_base.sh`. Bump the version and build numbers there, then re-run setup:
```
./setup.sh casual
```
