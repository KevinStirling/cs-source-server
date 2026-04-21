#!/usr/bin/env bash
#
# Zombie Reloaded server mods — installs server-specific plugins.
# Base mods (MetaMod + SourceMod) are installed by setup.sh before this runs.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CSS_DIR="${GAME_DIR:?GAME_DIR must be set}/cstrike"
SPCOMP="${CSS_DIR}/addons/sourcemod/scripting/spcomp"
SM_INCLUDE="${CSS_DIR}/addons/sourcemod/scripting/include"

MOD_TEMP="$(mktemp -d)"
trap 'rm -rf "${MOD_TEMP}"' EXIT

# ---------------------------------------------------------------------------
# CSSFixes — fixes CSS engine crashes that SM 1.11 can trigger
# https://github.com/srcdslab/sm-ext-cssfixes
# ---------------------------------------------------------------------------
CSSFIXES_URL="https://github.com/srcdslab/sm-ext-cssfixes/releases/download/v1.19.0/sm-ext-cssfixes-ubuntu-20.04.tar.gz"

echo ">>> Installing CSSFixes extension..."
curl -sSL "${CSSFIXES_URL}" -o "${MOD_TEMP}/cssfixes.tar.gz"
tar -xzf "${MOD_TEMP}/cssfixes.tar.gz" -C "${CSS_DIR}"
echo ">>> CSSFixes installed."

# ---------------------------------------------------------------------------
# Zombie Reloaded — compiled from source against the local SM installation
# https://github.com/srcdslab/sm-plugin-zombiereloaded/
# ---------------------------------------------------------------------------
ZR_REPO="https://github.com/srcdslab/sm-plugin-zombiereloaded.git"
MC_REPO="https://github.com/srcdslab/sm-plugin-MultiColors.git"
AFK_REPO="https://github.com/srcdslab/sm-plugin-AFKManager.git"
TM_REPO="https://github.com/srcdslab/sm-plugin-TeamManager.git"

echo ">>> Cloning Zombie Reloaded source + dependencies..."
git clone --depth 1 "${ZR_REPO}" "${MOD_TEMP}/zr"
git clone --depth 1 "${MC_REPO}" "${MOD_TEMP}/mc"
git clone --depth 1 "${AFK_REPO}" "${MOD_TEMP}/afk"
git clone --depth 1 "${TM_REPO}" "${MOD_TEMP}/tm"

# Stage include dependencies alongside the ZR source
ZR_SCRIPTING="${MOD_TEMP}/zr/src/addons/sourcemod/scripting"
cp -r "${MOD_TEMP}/mc/addons/sourcemod/scripting/include/multicolors"* "${ZR_SCRIPTING}/include/"
cp "${MOD_TEMP}/afk/addons/sourcemod/scripting/include/AFKManager.inc" "${ZR_SCRIPTING}/include/"
cp "${MOD_TEMP}/tm/addons/sourcemod/scripting/include/TeamManager.inc" "${ZR_SCRIPTING}/include/"

# Compile against the installed SM
echo ">>> Compiling Zombie Reloaded..."
"${SPCOMP}" \
    -i"${SM_INCLUDE}" \
    -i"${ZR_SCRIPTING}/include" \
    -o"${MOD_TEMP}/zombiereloaded.smx" \
    "${ZR_SCRIPTING}/zombiereloaded.sp"

# Install compiled plugin
cp "${MOD_TEMP}/zombiereloaded.smx" "${CSS_DIR}/addons/sourcemod/plugins/"

# Install configs, gamedata, translations, and assets from common/
cp -r "${MOD_TEMP}/zr/common/"* "${CSS_DIR}"

echo ">>> Zombie:Reloaded compiled and installed."
