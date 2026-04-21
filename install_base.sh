#!/usr/bin/env bash
#
# Installs MetaMod:Source and SourceMod into a CS:S dedicated server.
# Intended to run during Docker image build (or standalone).
#
set -euo pipefail

CSS_DIR="${GAME_DIR:?GAME_DIR must be set}/cstrike"

# ---------------------------------------------------------------------------
# Version config — defaults can be overridden via environment variables.
# MetaMod:Source and SourceMod 1.11 are the latest branches for Source 1 games.
# ---------------------------------------------------------------------------
METAMOD_VERSION="${METAMOD_VERSION:-1.11}"
METAMOD_BUILD="${METAMOD_BUILD:-1148}"
SOURCEMOD_VERSION="${SOURCEMOD_VERSION:-1.11}"
SOURCEMOD_BUILD="${SOURCEMOD_BUILD:-6960}"

METAMOD_URL="https://mms.alliedmods.net/mmsdrop/${METAMOD_VERSION}/mmsource-${METAMOD_VERSION}.0-git${METAMOD_BUILD}-linux.tar.gz"
SOURCEMOD_URL="https://sm.alliedmods.net/smdrop/${SOURCEMOD_VERSION}/sourcemod-${SOURCEMOD_VERSION}.0-git${SOURCEMOD_BUILD}-linux.tar.gz"

TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TEMP_DIR}"' EXIT

# ---------------------------------------------------------------------------
# MetaMod:Source
# ---------------------------------------------------------------------------
echo ">>> Installing MetaMod:Source ${METAMOD_VERSION} (build ${METAMOD_BUILD})..."
curl -sSL "${METAMOD_URL}" -o "${TEMP_DIR}/metamod.tar.gz"
tar -xzf "${TEMP_DIR}/metamod.tar.gz" -C "${CSS_DIR}"

# MetaMod VDF — tells the engine to load MetaMod
mkdir -p "${CSS_DIR}/addons"
cat > "${CSS_DIR}/addons/metamod.vdf" <<'VDF'
"Plugin"
{
    "file"  "../cstrike/addons/metamod/bin/server"
}
VDF

echo "    MetaMod:Source installed to ${CSS_DIR}/addons/metamod"

# ---------------------------------------------------------------------------
# SourceMod
# ---------------------------------------------------------------------------
echo ">>> Installing SourceMod ${SOURCEMOD_VERSION} (build ${SOURCEMOD_BUILD})..."
curl -sSL "${SOURCEMOD_URL}" -o "${TEMP_DIR}/sourcemod.tar.gz"
tar -xzf "${TEMP_DIR}/sourcemod.tar.gz" -C "${CSS_DIR}"

echo "    SourceMod installed to ${CSS_DIR}/addons/sourcemod"

# ---------------------------------------------------------------------------
# Verify
# ---------------------------------------------------------------------------
echo ""
echo "--- Installation summary ---"
for d in "${CSS_DIR}/addons/metamod" "${CSS_DIR}/addons/sourcemod"; do
    if [ -d "$d" ]; then
        echo "  [OK] $d"
    else
        echo "  [FAIL] $d not found!" >&2
        exit 1
    fi
done
echo ">>> Plugin installation complete."
