#!/usr/bin/env bash
set -euo pipefail

SERVER="${1:?Usage: ./addmap.sh <server-name> <path-to-bsp>}"
BSP_FILE="${2:?Usage: ./addmap.sh <server-name> <path-to-bsp>}"

MAPS_DIR="instances/${SERVER}/css/cstrike/maps"
MAPCYCLE="instances/${SERVER}/css/cstrike/cfg/mapcycle.txt"

if [ ! -d "${MAPS_DIR}" ]; then
    echo "Error: ${MAPS_DIR} not found. Run ./setup.sh ${SERVER} first."
    exit 1
fi

if [ ! -f "${BSP_FILE}" ]; then
    echo "Error: ${BSP_FILE} not found."
    exit 1
fi

MAPNAME="$(basename "${BSP_FILE}" .bsp)"

# Copy map to server
echo ">>> Copying ${MAPNAME}.bsp to ${MAPS_DIR}/"
cp "${BSP_FILE}" "${MAPS_DIR}/"

# Compress for FastDL
echo ">>> Compressing for FastDL..."
bzip2 -kf "${MAPS_DIR}/${MAPNAME}.bsp"

# Add to mapcycle if not already present
touch "${MAPCYCLE}"
if ! grep -qx "${MAPNAME}" "${MAPCYCLE}"; then
    echo "${MAPNAME}" >> "${MAPCYCLE}"
    echo ">>> Added ${MAPNAME} to mapcycle.txt"
else
    echo ">>> ${MAPNAME} already in mapcycle.txt"
fi

echo ">>> Done. ${MAPNAME} is ready to play after next map change."
