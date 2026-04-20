#!/usr/bin/env bash
set -euo pipefail

SERVER="${1:?Usage: ./compress_maps.sh <server-name> (e.g., casual)}"
MAPS_DIR="instances/${SERVER}/css/cstrike/maps"

if [ ! -d "${MAPS_DIR}" ]; then
    echo "Error: ${MAPS_DIR} not found"
    exit 1
fi

count=0
for bsp in "${MAPS_DIR}"/*.bsp; do
    [ -f "${bsp}" ] || continue
    if [ ! -f "${bsp}.bz2" ] || [ "${bsp}" -nt "${bsp}.bz2" ]; then
        echo "Compressing $(basename "${bsp}")..."
        bzip2 -kf "${bsp}"
        count=$((count + 1))
    fi
done

echo ">>> Done. ${count} map(s) compressed."
