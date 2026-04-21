#!/usr/bin/env bash
#
# Casual server mods — installs server-specific plugins.
# Base mods (MetaMod + SourceMod) are installed by setup.sh before this runs.
#
set -euo pipefail

CSS_DIR="${GAME_DIR:?GAME_DIR must be set}/cstrike"
SM_DIR="${CSS_DIR}/addons/sourcemod"
SPCOMP="${SM_DIR}/scripting/spcomp"

# ---------------------------------------------------------------------------
# Zombie Reloaded 3 Franug Edition
# https://github.com/Franc1sco/sm-zombiereloaded-3-Franug-Edition
# ---------------------------------------------------------------------------
ZR_TEMP="$(mktemp -d)"
trap 'rm -rf "${ZR_TEMP}"' EXIT

echo ">>> Installing Zombie Reloaded..."
curl -sSL "https://github.com/Franc1sco/sm-zombiereloaded-3-Franug-Edition/archive/master.zip" \
    -o "${ZR_TEMP}/zombie.zip"
unzip "${ZR_TEMP}/zombie.zip" -d "${ZR_TEMP}"

ZR_EXTRACTED="${ZR_TEMP}/sm-zombiereloaded-3-Franug-Edition-master"

# Copy pre-compiled plugins
cp "${ZR_EXTRACTED}/plugin compiled (REQUIRED)/"*.smx \
    "${SM_DIR}/plugins/"

# Copy cstrike mod contents
cp -r "${ZR_EXTRACTED}/cstrike/"* \
    "${CSS_DIR}/"

