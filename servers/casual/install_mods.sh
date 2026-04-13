#!/usr/bin/env bash
#
# Casual server mods — installs base plugins (MetaMod + SourceMod) only.
# Add server-specific plugins below the base install.
#
set -euo pipefail

# Install base (MetaMod:Source + SourceMod)
/home/steam/install_base.sh

# ---------------------------------------------------------------------------
# Add casual-specific plugins below, e.g.:
# CSS_DIR="/home/steam/css/cstrike"
# curl -sSL "https://example.com/plugin.smx" \
#     -o "${CSS_DIR}/addons/sourcemod/plugins/plugin.smx"
# ---------------------------------------------------------------------------

echo ">>> Casual server mods installed."
