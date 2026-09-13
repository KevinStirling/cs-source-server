#!/usr/bin/env bash
set -euo pipefail

SERVER="${1:?Usage: ./compress_files.sh <server-name> (e.g., casual)}"
CSTRIKE_DIR="instances/${SERVER}/css/cstrike"

if [ ! -d "${CSTRIKE_DIR}" ]; then
    echo "Error: ${CSTRIKE_DIR} not found"
    exit 1
fi

total_compressed=0
total_skipped=0

# compress_dir <subdir> [find-name-args...]
#   Walks <subdir> recursively and bzip2s every matching file that does not yet
#   have an up-to-date .bz2 alongside it. Existing archives are left alone.
compress_dir() {
    local subdir="$1"
    shift
    local dir="${CSTRIKE_DIR}/${subdir}"

    if [ ! -d "${dir}" ]; then
        echo ">>> ${subdir}/ not found, skipping."
        return
    fi

    local compressed=0
    local skipped=0
    local file

    echo ">>> Scanning ${subdir}/..."
    while IFS= read -r -d '' file; do
        # bzip2 copies the source mtime onto the archive but drops sub-second
        # precision, so compare whole seconds instead of using -nt.
        if [ -f "${file}.bz2" ] && \
           [ "$(stat -c %Y "${file}")" -le "$(stat -c %Y "${file}.bz2")" ]; then
            skipped=$((skipped + 1))
            continue
        fi
        echo "  Compressing ${file#"${CSTRIKE_DIR}"/}..."
        bzip2 -kf "${file}"
        compressed=$((compressed + 1))
    done < <(find "${dir}" -type f ! -name '*.bz2' "$@" -print0)

    echo "    ${compressed} compressed, ${skipped} already up to date."
    total_compressed=$((total_compressed + compressed))
    total_skipped=$((total_skipped + skipped))
}

compress_dir maps -name '*.bsp'
compress_dir materials
compress_dir models
compress_dir sound

echo ">>> Done. ${total_compressed} file(s) compressed, ${total_skipped} already up to date."
