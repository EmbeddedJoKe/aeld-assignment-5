#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
source ./shared.sh
mkdir -p base_external/configs
make -C buildroot BR2_EXTERNAL=../base_external \
    BR2_DEFCONFIG="$AESD_MODIFIED_DEFCONFIG_REL_BUILDROOT" savedefconfig
