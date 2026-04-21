#!/usr/bin/env bash
#
# Zombie Reloaded server mods — installs server-specific plugins.
# Base mods (MetaMod + SourceMod) are installed by setup.sh before this runs.
#
set -euo pipefail

CSS_DIR="${GAME_DIR:?GAME_DIR must be set}/cstrike"
SM_DIR="${CSS_DIR}/addons/sourcemod"
SPCOMP="${SM_DIR}/scripting/spcomp"

# ---------------------------------------------------------------------------
# Zombie Reloaded 3 Franug Edition — compiled from source for CS:S
# https://github.com/Franc1sco/sm-zombiereloaded-3-Franug-Edition
# Requires SourceMod 1.10 (set via server.env)
# ---------------------------------------------------------------------------
ZR_TEMP="$(mktemp -d)"
trap 'rm -rf "${ZR_TEMP}"' EXIT

echo ">>> Installing Zombie Reloaded..."
curl -sSL "https://github.com/Franc1sco/sm-zombiereloaded-3-Franug-Edition/archive/master.zip" \
    -o "${ZR_TEMP}/zombie.zip"
unzip "${ZR_TEMP}/zombie.zip" -d "${ZR_TEMP}"

ZR_EXTRACTED="${ZR_TEMP}/sm-zombiereloaded-3-Franug-Edition-master"
ZR_SRC="${ZR_EXTRACTED}/src"

# Copy ZR include files so spcomp can resolve dependencies
cp "${ZR_SRC}/include/"*.inc "${SM_DIR}/scripting/include/"
cp -r "${ZR_SRC}/include/zr" "${SM_DIR}/scripting/include/"

# Compile plugins from source
for sp in "${ZR_SRC}/zombiereloaded.sp" "${ZR_SRC}/zombiereloaded_sounds.sp"; do
    name="$(basename "${sp}" .sp)"
    echo "    Compiling ${name}.sp..."
    "${SPCOMP}" -i"${SM_DIR}/scripting/include" -i"${ZR_SRC}" "${sp}" -o"${SM_DIR}/plugins/${name}.smx"
done

# Copy CS:S mod contents (configs, translations, models, sounds, materials)
cp -r "${ZR_EXTRACTED}/cstrike/"* \
    "${CSS_DIR}/"

