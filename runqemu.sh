#!/bin/bash
#Script to run QEMU for buildroot as the default configuration qemu_aarch64_virt_defconfig
# Host forwarding: 10022 -> guest SSH/22, 9000 -> guest aesdsocket/9000.
#Author: Siddhant Jajoo.
set -euo pipefail
cd "$(dirname "$0")"

exec qemu-system-aarch64 \
    -M virt  \
    -cpu cortex-a53 -nographic -smp 1 \
    -kernel buildroot/output/images/Image \
    -append "rootwait root=/dev/vda console=ttyAMA0" \
    -netdev user,id=eth0,hostfwd=tcp:127.0.0.1:10022-:22,hostfwd=tcp:127.0.0.1:9000-:9000 \
    -device virtio-net-device,netdev=eth0 \
    -drive file=buildroot/output/images/rootfs.ext4,if=none,format=raw,id=hd0 \
    -device virtio-blk-device,drive=hd0 -device virtio-rng-pci
