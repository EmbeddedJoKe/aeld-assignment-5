#!/bin/bash
# Validate the built image and copy the required result into the source repo.
set -euo pipefail
cd "$(dirname "$0")"
source_repo=$(realpath "${1:?Usage: ./validate-local.sh /path/to/source-repository}")
export PATH="$PWD/host-tools/bin:$PATH"
command -v sshpass >/dev/null
known_hosts=$(mktemp)
qemu_pid=
cleanup() {
    if [ -n "$qemu_pid" ]; then
        kill "$qemu_pid" 2>/dev/null || true
        wait "$qemu_pid" 2>/dev/null || true
    fi
    rm -f "$known_hosts"
}
trap cleanup EXIT
ssh_options=(-o StrictHostKeyChecking=no -o UserKnownHostsFile="$known_hosts"
             -o ConnectTimeout=3 -o ConnectionAttempts=1)
guest() {
    sshpass -p root ssh "${ssh_options[@]}" -p 10022 root@localhost "$@"
}

file buildroot/output/target/usr/bin/writer | grep 'ARM aarch64'
for executable in writer finder.sh finder-test.sh tester.sh; do
    test -x "buildroot/output/target/usr/bin/$executable"
done
./runqemu.sh > qemu-validation.log 2>&1 &
qemu_pid=$!
ready=0
for attempt in $(seq 1 60); do
    kill -0 "$qemu_pid"
    if guest true >/dev/null 2>&1; then
        ready=1
        break
    fi
    sleep 2
done
if [ "$ready" -ne 1 ]; then
    echo "QEMU SSH did not become ready within the startup timeout." >&2
    exit 1
fi

guest 'uname -m; command -v writer finder.sh finder-test.sh tester.sh; cat /etc/finder-app/conf/username.txt'
guest 'cd /; finder-test.sh'
guest 'cd /tmp; /usr/bin/finder-test.sh 20 AESD_IS_AWESOME alternate'
guest 'cd /root; tester.sh'
guest 'cd /etc; finder-test.sh'
guest 'grep -F "The number of files are 10 and the number of matching lines are 10" /tmp/assignment4-result.txt'
guest 'grep -F "writer: Writing AELD_IS_FUN" /var/log/messages'
guest 'writer >/dev/null 2>&1; test "$?" -eq 1'
guest 'writer /tmp/missing-parent/file test >/dev/null 2>&1; test "$?" -eq 1'
mkdir -p "$source_repo/assignments/assignment4"
# Dropbear supplies legacy SCP. -O also supports OpenSSH hosts using SFTP by default.
sshpass -p root scp -O "${ssh_options[@]}" -P 10022 \
    root@localhost:/tmp/assignment4-result.txt \
    "$source_repo/assignments/assignment4/assignment4-result.txt"
grep -F 'The number of files are 10 and the number of matching lines are 10' \
    "$source_repo/assignments/assignment4/assignment4-result.txt"
echo 'Local QEMU, SSH, finder, writer syslog, and SCP validation passed.'
