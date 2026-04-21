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
MOD_TEMP="$(mktemp -d)"
trap 'rm -rf "${MOD_TEMP}"' EXIT

# ---------------------------------------------------------------------------
# CSSFixes — fixes CSS engine crashes that SM 1.11 can trigger
# https://github.com/srcdslab/sm-ext-cssfixes
# ---------------------------------------------------------------------------
CSSFIXES_URL="https://github.com/srcdslab/sm-ext-cssfixes/releases/download/1.17.0/sm-ext-cssfixes-1.17.0-linux.tar.gz"

echo ">>> Installing CSSFixes extension..."
curl -sSL "${CSSFIXES_URL}" -o "${MOD_TEMP}/cssfixes.tar.gz"
tar -xzf "${MOD_TEMP}/cssfixes.tar.gz" -C "${CSS_DIR}"
echo ">>> CSSFixes installed."

# ---------------------------------------------------------------------------
# Zombie Reloaded fork by srcdslab
# https://github.com/srcdslab/sm-plugin-zombiereloaded/
# ---------------------------------------------------------------------------
echo ">>> Installing Zombie Reloaded..."
curl -sSL "https://github.com/srcdslab/sm-plugin-zombiereloaded/releases/download/latest/sm-plugin-zombiereloaded-latest.tar.gz" \
    -o "${MOD_TEMP}/sm-plugin-zombiereloaded-latest.tar.gz"
tar -xzf "${MOD_TEMP}/sm-plugin-zombiereloaded-latest.tar.gz" -C "${MOD_TEMP}"

# Copy common dir into cstrike
cp -r "${MOD_TEMP}/common/"* "${CSS_DIR}"

echo ">>> Zombie:Reloaded installed."
