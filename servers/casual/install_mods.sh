#!/usr/bin/env bash
#
# Casual server mods — installs base plugins (MetaMod + SourceMod) only.
# Add server-specific plugins below the base install.
#
set -euo pipefail

# Install base (MetaMod:Source + SourceMod)
/home/steam/install_base.sh

# ---------------------------------------------------------------------------
# Ultimate Mapchooser (UMC) — compiled from source
# https://github.com/Steell/Ultimate-Mapchooser
# ---------------------------------------------------------------------------
CSS_DIR="/home/steam/css-base/cstrike"
SM_DIR="${CSS_DIR}/addons/sourcemod"
SPCOMP="${SM_DIR}/scripting/spcomp"

UMC_TEMP="$(mktemp -d)"
trap 'rm -rf "${UMC_TEMP}"' EXIT

echo ">>> Installing Ultimate Mapchooser..."
curl -sSL "https://github.com/Steell/Ultimate-Mapchooser/archive/refs/heads/master.tar.gz" \
    -o "${UMC_TEMP}/umc.tar.gz"
tar -xzf "${UMC_TEMP}/umc.tar.gz" -C "${UMC_TEMP}"

UMC_SRC="${UMC_TEMP}/Ultimate-Mapchooser-master"

# Copy include files so spcomp can resolve dependencies
cp "${UMC_SRC}/addons/sourcemod/scripting/include/"*.inc \
    "${SM_DIR}/scripting/include/"

# Compile all UMC plugins
for sp in "${UMC_SRC}/addons/sourcemod/scripting/"*.sp; do
    name="$(basename "${sp}" .sp)"
    echo "    Compiling ${name}.sp..."
    "${SPCOMP}" -i"${SM_DIR}/scripting/include" "${sp}" -o"${SM_DIR}/plugins/${name}.smx"
done

# Copy configs, translations, and mapcycle
cp "${UMC_SRC}/addons/sourcemod/configs/"* "${SM_DIR}/configs/"
cp -r "${UMC_SRC}/addons/sourcemod/translations/"* "${SM_DIR}/translations/"
cp "${UMC_SRC}/umc_mapcycle.txt" "${CSS_DIR}/cfg/"

echo ">>> Ultimate Mapchooser installed."
