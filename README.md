# Overview

This repository contains assignment starter code for buildroot based assignments for the course Advanced Embedded Software Design, ECEN 5713

It also contains instructions related to modifying your buildroot project to use with supported hardware platforms.  See [this wiki page](https://github.com/cu-ecen-5013/buildroot-assignments-base/wiki/Supported-Hardware) for details.

## Assignment 4 Part 2

Buildroot is a submodule pinned to **2024.02.13**, commit
`e687e3815f76c1c5ea9fb52b6558bedfe53ab117`. The external tree is
`base_external`, named `project_base`. The saved configuration is
`base_external/configs/aesd_qemu_defconfig`.

```sh
./build.sh
./build.sh
./runqemu.sh
```

The first build also compiles the image after loading the configuration.
Downloads default to `${HOME}/.dl` and survive `./clean.sh`, which runs
Buildroot's `distclean`. The saved configuration uses the supported Arm
AArch64 external toolchain, Linux 6.1.44, an ext4 root filesystem, DHCP,
Dropbear, and the `aesd-assignments` package. The host supplies QEMU.

Inside QEMU, log in as `root` with password `root`, then run `finder-test.sh`
from any directory. Applications are installed in `/usr/bin`, configuration
in `/etc/finder-app/conf`, output in `/tmp/assignment4-result.txt`, and writer
syslog messages in `/var/log/messages`.

QEMU forwards host `127.0.0.1:10022` to guest port 22:

```sh
ssh -p 10022 root@localhost
scp -O -P 10022 root@localhost:/tmp/assignment4-result.txt /path/to/source/assignments/assignment4/
```

For repeatable local checks, stop any QEMU instance using port 10022 first:

```sh
./validate-local.sh /path/to/source-repository
./full-test.sh
./clean.sh
./build.sh
./build.sh
./validate-local.sh /path/to/source-repository
```

`validate-local.sh` boots and stops its own QEMU process, checks SSH,
finder execution from several directories, writer errors and syslog, and
copies the result by SCP. Install `sshpass` on the host. An ignored
`host-tools/bin/sshpass` can provide a user-local installation when needed.
The native instructor test helper directory is added to PATH by
`full-test.sh`; the instructor CI container also supplies these helpers.

The package fetches source through Git SSH. Its temporary patch mirrors the
source working-tree changes while publication awaits approval. Once the
updated source commit is pushed, update `AESD_ASSIGNMENTS_VERSION` to that
commit and remove the patch before the final Buildroot submission.

The separate GitHub runner uses `actions-runner-assignment4/`, name and
label `aeld-assignment-4`. That directory and the host tools are ignored by
Git. `register-runner.sh` refuses to overwrite an existing registration.
The Assignment 3 runner is independent and must remain unchanged.
