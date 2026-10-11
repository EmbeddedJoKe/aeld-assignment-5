#!/bin/bash
# Repair only inconsistent host-e2fsprogs generated state; retain the evidence.
set -euo pipefail
output_dir=${1:-buildroot/output}
for package_dir in "$output_dir"/build/host-e2fsprogs-*; do
    [ -d "$package_dir" ] || continue
    reason=
    if [ -e "$package_dir/.stamp_extracted" ] && [ ! -s "$package_dir/configure" ]; then
        reason="extraction stamp exists but configure is missing or empty"
    elif { [ -e "$package_dir/.stamp_configured" ] ||
           [ -e "$package_dir/.stamp_built" ] ||
           [ -e "$package_dir/.stamp_host_installed" ]; } &&
         [ ! -s "$package_dir/Makefile" ]; then
        reason="configuration/build stamp exists but Makefile is missing or empty"
    fi
    if [ -n "$reason" ]; then
        mkdir -p "$output_dir/recovery"
        backup_dir=$(mktemp -d "$output_dir/recovery/$(basename "$package_dir").XXXXXX")
        mv -- "$package_dir" "$backup_dir/package"
        printf 'Recovering host-e2fsprogs: %s. Preserved package state in %s/package\n' \
            "$reason" "$backup_dir"
    fi
done
