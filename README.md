# Overview

This repository contains assignment starter code for buildroot based assignments for the course Advanced Embedded Software Design, ECEN 5713

It also contains instructions related to modifying your buildroot project to use with supported hardware platforms.  See [this wiki page](https://github.com/cu-ecen-5013/buildroot-assignments-base/wiki/Supported-Hardware) for details.

## Assignment 5 Part 2

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

The package also builds `server/aesdsocket` and installs it to `/usr/bin`.
The BusyBox-compatible service is installed as `/etc/init.d/S99aesdsocket`.
It starts `aesdsocket -d` automatically at boot and sends SIGTERM at shutdown,
waiting for the server to exit and remove `/var/tmp/aesdsocketdata`.

QEMU forwards host `127.0.0.1:10022` to guest port 22 and
`127.0.0.1:9000` to guest port 9000:

```sh
ssh -p 10022 root@localhost
bash assignment-autotest/test/assignment5-buildroot/sockettest.sh
```

For local validation, ports 10022 and 9000 must be available and no unrelated
QEMU instance should be running: the instructor full test uses `killall`.
`validate-local.sh` owns its QEMU process and checks SSH, automatic startup,
socket responses, syslog, repeated service starts/stops, SIGINT cleanup, and
graceful halt followed by reboot with empty history.

```sh
./validate-local.sh
./full-test.sh
```

Install `sshpass` on the host. An ignored
`host-tools/bin/sshpass` can provide a user-local installation when needed.
The native instructor test helper directory is added to PATH by
`full-test.sh`; the instructor CI container also supplies these helpers.

The package fetches the published Assignment 5 source commit through
Git SSH, including source submodules. It builds the source directly without
local overrides or package patches.

The separate GitHub runner uses `actions-runner-assignment5/`, name and
label `aeld-assignment-5`. That directory and the host tools are ignored by
Git. `register-runner.sh` refuses to overwrite an existing registration.
The Assignment 3 and 4 runners retain their registrations and services.
`./start-runner.sh` enables the separate user service
`aeld-assignment5-runner.service`; it uses no sudo and starts on user login.
Inspect it with `systemctl --user status aeld-assignment5-runner.service`.
The repository needs the `SSH_PRIVATE_KEY` Actions secret for the source fetch.
The workflow runs the instructor full build and socket test, with queued runs
that do not cancel active jobs.
