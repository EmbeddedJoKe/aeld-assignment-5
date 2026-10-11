#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
source ./shared.sh

# Serialize builds and recovery in this checkout before touching package state.
mkdir -p buildroot/output
exec 9>buildroot/output/.aesd-build.lock
if ! flock -n 9; then
    echo "Another Buildroot build is active in this checkout." >&2
    exit 1
fi
./recover-build-state.sh buildroot/output

# Override BR2_DL_DIR to share a persistent cache with other checkouts.
export BR2_DL_DIR="${BR2_DL_DIR:-${HOME}/.dl}"
mkdir -p "$BR2_DL_DIR"
git submodule update --init --recursive

if [ ! -f buildroot/.config ]; then
    if [ -f "$AESD_MODIFIED_DEFCONFIG" ]; then
        make -C buildroot BR2_EXTERNAL=../base_external \
            BR2_DEFCONFIG="$AESD_MODIFIED_DEFCONFIG_REL_BUILDROOT" defconfig
    else
        make -C buildroot BR2_EXTERNAL=../base_external "$AESD_DEFAULT_DEFCONFIG"
    fi
fi

# Build on the first invocation, including when defconfig was just generated.
make -C buildroot BR2_EXTERNAL=../base_external "$@"
