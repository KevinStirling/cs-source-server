#!/usr/bin/env bash
#
# Entrypoint for CSS server containers.
# Seeds the mounted game directory from the staged image build on first run,
# then starts srcds.
#
set -euo pipefail

STAGE_DIR="/home/steam/css-base"
LIVE_DIR="/home/steam/css"

# If the live directory is empty (fresh mount), seed it from the staged build.
if [ -z "$(ls -A "${LIVE_DIR}" 2>/dev/null)" ]; then
    echo ">>> First run: seeding game data from image into mounted volume..."
    cp -a "${STAGE_DIR}/." "${LIVE_DIR}/"
    echo ">>> Seeding complete."
else
    echo ">>> Existing game data found, skipping seed."
fi

exec "${LIVE_DIR}/srcds_run" "$@"
