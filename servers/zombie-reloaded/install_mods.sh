#!/usr/bin/env bash
#
# Zombie Reloaded server mods — installs server-specific plugins.
# Base mods (MetaMod + SourceMod) are installed by setup.sh before this runs.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CSS_DIR="${GAME_DIR:?GAME_DIR must be set}/cstrike"

# ---------------------------------------------------------------------------
# Zombie Reloaded fork by srcdslab
# https://github.com/srcdslab/sm-plugin-zombiereloaded/
# ---------------------------------------------------------------------------
ZOM_TEMP="$(mktemp -d)"
trap 'rm -rf "${ZOM_TEMP}"' EXIT

echo ">>> Installing Zombie Reloaded..."
curl -sSL "https://github.com/srcdslab/sm-plugin-zombiereloaded/releases/download/latest/sm-plugin-zombiereloaded-latest.tar.gz" \
    -o "${ZOM_TEMP}/sm-plugin-zombiereloaded-latest.tar.gz"
tar -xzf "${ZOM_TEMP}/sm-plugin-zombiereloaded-latest.tar.gz" -C "${ZOM_TEMP}"

# Copy common dir into cstrike
cp -r "${ZOM_TEMP}/common/"* "${CSS_DIR}" 

echo ">>> Zombie:Reloaded installed."
