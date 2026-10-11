# Assignment 4 Part 2 checklist

- [x] Inspect both repositories, starter scripts, source code, and instructor tests.
- [x] Preserve Assignment 3 runner, source tags, origin remotes, and existing work.
- [x] Add Buildroot submodule at 2024.02.13 (e687e3815f76c1c5ea9fb52b6558bedfe53ab117).
- [x] Implement project_base external tree and SSH Git aesd-assignments package.
- [x] Update source finder test and compiler handling; include matching package patch.
- [x] Generate and save AArch64 QEMU defconfig with Dropbear and root password.
- [x] Build Linux image through build.sh using an external download cache.
- [x] Verify AArch64 writer and installed scripts/configuration.
- [x] Boot runqemu.sh and verify SSH at localhost:10022.
- [x] Run finder-test.sh from multiple directories and verify writer syslog.
- [x] SCP assignment4-result.txt into source assignments/assignment4.
- [ ] Execute instructor full-test.sh and source regression tests.
- [x] Register separate GitHub Actions runner with approval (kept offline during local builds).
- [ ] Record final results and review/commit/push/tag commands.

No pushes or final tags are authorized. No existing tags or origin remotes
will be changed. Generated Buildroot files and downloads stay untracked.

## Review against instructor documents

Read both instruction and demo files completely from ~/Instructions. Those
files are outside the repository and are not added to Git. Written
instructions take precedence over transcript transcription errors.

- Buildroot is exactly release 2024.02.13, recorded in local commit 2d2d943.
- Source package uses Git SSH and an immutable published source revision.
  A package patch mirrors the unpublished source changes for local validation;
  final submission should advance to the updated source commit after an
  approved push and remove that patch.
- project_base external tree, /usr/bin installs, CC handling, /etc/finder-app/conf,
  result path, Dropbear, root password, and port 10022 match the requirements.
- build.sh supports both the starter default defconfig and saved custom config.
  It builds on its first invocation; a second invocation is supported.
- Supported external Arm 13.2.rel1 toolchain reduces build time; Buildroot stays
  at the instructor release. Host QEMU is installed, so redundant host-QEMU
  compilation is disabled.
- build.sh defaults to ${HOME}/.dl, independent of machine-specific paths.
- Actual clean rebuild, fresh-checkout build, full-test, and SCP verification
  must complete before the new runner starts.
- sshpass is installed user-locally because sudo requires an interactive
  password. System installation remains an optional host setup command.
- Existing runner metadata hashes are unchanged. No pushes or tags have run.
