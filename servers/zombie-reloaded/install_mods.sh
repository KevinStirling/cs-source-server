#!/usr/bin/env bash
#
# Zombie Reloaded server mods — installs server-specific plugins.
# Base mods (MetaMod + SourceMod) are installed by setup.sh before this runs.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CSS_DIR="${GAME_DIR:?GAME_DIR must be set}/cstrike"

# ---------------------------------------------------------------------------
# Zombie:Reloaded 3.1 by Greyscale/rhelgeby (original CS:S version)
# https://forums.alliedmods.net/showthread.php?t=205567
# ---------------------------------------------------------------------------
ZR_ZIP="${SCRIPT_DIR}/zombiereloaded-3.1-r733.zip"

if [ ! -f "${ZR_ZIP}" ]; then
    echo "Error: ${ZR_ZIP} not found." >&2
    echo "Download from https://forums.alliedmods.net/showthread.php?t=205567" >&2
    echo "and place the zip in ${SCRIPT_DIR}/" >&2
    exit 1
fi

echo ">>> Installing Zombie:Reloaded 3.1..."
ZR_TEMP="$(mktemp -d)"
trap 'rm -rf "${ZR_TEMP}"' EXIT

unzip "${ZR_ZIP}" -d "${ZR_TEMP}"
cp -r "${ZR_TEMP}/"* "${CSS_DIR}/"

echo ">>> Zombie:Reloaded installed."
