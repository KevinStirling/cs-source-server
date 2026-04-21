#!/usr/bin/env bash
set -euo pipefail

SERVER="${1:?Usage: ./setup.sh <server-name> (e.g., casual)}"
SERVER_DIR="servers/${SERVER}"

if [ ! -d "${SERVER_DIR}" ]; then
    echo "Error: server config not found at ${SERVER_DIR}"
    exit 1
fi

INSTANCE_DIR="instances/${SERVER}"
GAME_DIR="$(pwd)/${INSTANCE_DIR}/css"
mkdir -p "${GAME_DIR}"

# Download steamcmd if needed
if [ ! -f "steamcmd/steamcmd.sh" ]; then
    echo ">>> Downloading SteamCMD..."
    mkdir -p steamcmd
    curl -sSL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
        | tar -xz -C steamcmd
fi

# Install CS:S dedicated server
echo ">>> Installing CS:S dedicated server..."
attempts=0
until ./steamcmd/steamcmd.sh \
    +force_install_dir "${GAME_DIR}" \
    +login anonymous \
    +app_update 232330 validate \
    +quit; do
    attempts=$((attempts + 1))
    if [ "$attempts" -ge 5 ]; then
        echo "steamcmd failed after $attempts attempts"
        exit 1
    fi
    echo "steamcmd exited $?, retrying (attempt $((attempts + 1))/5)..."
done

# Install MetaMod + SourceMod + server-specific mods
export GAME_DIR

# Source per-server version overrides if present
if [ -f "${SERVER_DIR}/server.env" ]; then
    set -a
    . "${SERVER_DIR}/server.env"
    set +a
fi

./install_base.sh
"${SERVER_DIR}/install_mods.sh"

# Set up steamclient.so for runtime
mkdir -p "${INSTANCE_DIR}/sdk32"
cp steamcmd/linux32/steamclient.so "${INSTANCE_DIR}/sdk32/"

echo ""
echo ">>> Setup complete: ${INSTANCE_DIR}"
echo ">>> Start with: docker compose up"
