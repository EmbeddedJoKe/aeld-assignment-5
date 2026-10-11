# Assignment 4 Part 2 implementation and validation

## Files

In the source repository, modified `finder-app/Makefile` and
`finder-app/finder-test.sh`; added
`assignments/assignment4/assignment4-result.txt` through SCP from QEMU.
No changes were made to the completed threading/system-call implementations,
existing workflow, existing tags, or origin remote. The existing untracked
`testfile.txt` remains untracked.

In the Buildroot repository, added the Buildroot submodule, external-tree
`Config.in`, `external.desc`, `external.mk`, saved `aesd_qemu_defconfig`,
`clean.sh`, `validate-local.sh`, `register-runner.sh`, `start-runner.sh`,
checklist, and this report.
Updated package configuration/install rules, build/save/run/test scripts,
username configuration, runner label, README, and ignore rules. Initial
validation used a package patch mirroring unpublished source changes. After
approved source publication, that patch was removed and the package now
builds the published source directly.

## Buildroot configuration

- Buildroot: `2024.02.13`, commit
  `e687e3815f76c1c5ea9fb52b6558bedfe53ab117`.
- External tree: `base_external`, name `project_base`.
- AArch64 Cortex-A53; supported Arm 13.2.rel1 external toolchain.
- Linux 6.1.44 and upstream QEMU AArch64 kernel configuration.
- ext4 root filesystem, DHCP on eth0, BusyBox, Dropbear, aesd-assignments.
- Development root password: `root`; SSH forwarding: localhost port 10022.
- Downloads: `${HOME}/.dl`, preserved by distclean. Installed host QEMU is used.
- Applications: `/usr/bin/{writer,finder.sh,finder-test.sh,tester.sh}`;
  `tester.sh` is a symlink to finder-test.sh.
- Configuration: `/etc/finder-app/conf/{username.txt,assignment.txt}`.
- Finder output: `/tmp/assignment4-result.txt`; syslog: `/var/log/messages`.

## Git state

Local source commit: `e4f36a0` (finder/CC updates and SCP result).
Local Buildroot commits: `2d2d943` (release pin), `832e9ae` (implementation).
Existing assignment tags and origin URLs are preserved.
Generated binaries, output directories, downloads, host tools, runner files,
credentials, and the two instruction/transcript files are excluded from commits.
Source commit e4f36a0 was pushed with explicit approval. Buildroot publication
is awaiting approval. No final tags have run.

The final package fetches published source commit
`e4f36a0f5e130ee40cbbd0d5e986c41a77720b74` over Git SSH, with its source
submodules, and applies no package patch or local source override.

## Commands executed

Key implementation/validation commands (inspection commands omitted):

```sh
git submodule add https://gitlab.com/buildroot.org/buildroot/ buildroot
git -C buildroot checkout 2024.02.13
git add .gitmodules buildroot
git commit -m 'Pin Buildroot submodule to release 2024.02.13'
make -C buildroot BR2_EXTERNAL=../base_external BR2_DEFCONFIG=../base_external/configs/aesd_qemu_defconfig defconfig
./save-config.sh
BR2_DL_DIR=/tmp/aeld-buildroot-dl ./build.sh
./build.sh
./validate-local.sh /home/devjo/aeld-assignment-1
./full-test.sh
./clean.sh
./build.sh
./build.sh
./validate-local.sh /home/devjo/aeld-assignment-1
```

Also cloned the committed setup to `/tmp/aeld-assignment4-fresh`, initialized
the recorded upstream submodules using local Git object references to reduce
downloads, ran build.sh twice, and validated that checkout's image. Source
full-test.sh and a native finder test from `/tmp` were run. Makefile probes
verified caller CC and CROSS_COMPILE handling. Readelf/file verified AArch64.
The validator uses `scp -O -P 10022` for Dropbear's legacy SCP protocol.

The approved runner registration script and SSH_PRIVATE_KEY secret setup ran.
Private key contents were sent directly to GitHub and were never printed or
committed. After all local clean/fresh/full tests passed, the separate runner was started
through start-runner.sh as user service `aeld-assignment4-runner.service`.
GitHub reports it online. A shell background launch did not persist, so the
user service provides a managed start without sudo or changes to the old runner.

## Test results

| Check | Result |
| --- | --- |
| Source full-test.sh, including threading tests | PASS; 6 unit tests, 0 failures |
| Native finder from /tmp | PASS |
| Corrected build.sh and initial image | PASS |
| Initial QEMU/SSH/finder/syslog/SCP | PASS |
| Initial instructor Buildroot full-test.sh | PASS, exit 0 |
| Actual clean.sh, then two build.sh invocations | PASS, exit 0 |
| Fresh committed checkout, two build.sh invocations | PASS, exit 0 |
| QEMU/SSH/finder/syslog/SCP after clean rebuild | PASS, exit 0 |
| QEMU/SSH/finder/syslog/SCP from fresh checkout | PASS, exit 0 |
| Instructor full-test.sh after reproducibility tests | PASS, exit 0 |
| Source GitHub Actions workflow at e4f36a0 | PASS |
| Direct published-source rebuild, no patch | PASS, exit 0 |
| Final published-source QEMU and instructor full-test | PASS, exit 0 |
| Buildroot GitHub Actions workflow | PENDING approved publication |

Finder checks covered `/`, `/tmp`, `/root`, and `/etc`, default 10-file tests,
20-file/custom-string tests, tester.sh alias, and expected writer errors.
Writer syslog entries were observed, and the required result was copied by
SCP into the source repository. Clean and fresh-checkout writer binaries match.

The first build produced its images but its wrapper exited 2 because build.sh
was edited while that invocation was running. The current script passed syntax
checks, rerun, full-test, clean rebuild, and fresh-checkout builds. This is
resolved. Initial download mirror failures recovered through Buildroot mirrors.
Patch-context whitespace triggered git diff --check; other files passed and
the actual patch applied and built successfully.

## Remaining work and review commands

Local clean/fresh testing completed successfully and the new runner is online.
GitHub has no published Buildroot workflow yet. Source publication was
approved and succeeded; Buildroot publication requires explicit approval.
Final tags remain separate.

Source Actions result:
https://github.com/EmbeddedJoKe/aeld-assignment-3-and-later/actions/runs/38113373287

sshpass is installed in ignored `host-tools/bin` for native testing. System
installation attempted with sudo but requires your interactive password:

```sh
sudo apt-get install -y sshpass
```

The source is published and the package has been advanced to it without a
patch. After approval, publish the final Buildroot commit and verify Actions.
Final course tags, only after successful Actions:

```sh
git -C /home/devjo/aeld-assignment-1 tag assignment-4-complete
git -C /home/devjo/aeld-assignment-1 push origin assignment-4-complete
git -C /home/devjo/aeld-assignment-4 tag assignment-4-complete
git -C /home/devjo/aeld-assignment-4 push origin assignment-4-complete
```

Logs (ignored): `build.log`, `build-rerun.log`, `local-validation.log`,
`full-test-local.log`, `clean-build.log`, `clean-validation.log`,
`full-test-clean.log`, `build-published-source.log`, `published-validation.log`,
`full-test-published.log`; fresh-build/validation logs are in the temporary checkout.
Existing runner registration/service hashes remain unchanged. No existing
Assignment 3 runner process has been interrupted or reconfigured.

Runner service commands (Assignment 4 only):

```sh
systemctl --user status aeld-assignment4-runner.service
journalctl --user -u aeld-assignment4-runner.service -n 30 --no-pager
./start-runner.sh
```

The user service starts at user login. The existing Assignment 3 runner's
system service, registration, credentials, and work directory were not changed.

Final local commands with the directly published source also passed:

```sh
./build.sh
./validate-local.sh /home/devjo/aeld-assignment-1
./full-test.sh
```
