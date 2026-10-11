#!/bin/bash
# Supplemental lifecycle checks around the unchanged instructor socket test.
set -euo pipefail
cd "$(dirname "$0")"
export PATH="$PWD/host-tools/bin:$PATH"
command -v sshpass >/dev/null
known_hosts=$(mktemp)
qemu_pid=
cleanup() {
    if [ -n "$qemu_pid" ] && kill -0 "$qemu_pid" 2>/dev/null; then
        guest 'poweroff' >/dev/null 2>&1 || true
        for attempt in $(seq 1 15); do
            kill -0 "$qemu_pid" 2>/dev/null || break
            sleep 1
        done
        if kill -0 "$qemu_pid" 2>/dev/null; then
            kill "$qemu_pid" 2>/dev/null || true
        fi
        wait "$qemu_pid" 2>/dev/null || true
    fi
    rm -f "$known_hosts"
}
trap cleanup EXIT
ssh_options=(-o StrictHostKeyChecking=no -o UserKnownHostsFile="$known_hosts"
             -o ConnectTimeout=3 -o ConnectionAttempts=1)
guest() {
    sshpass -p root ssh "${ssh_options[@]}" -p 10022 root@127.0.0.1 "$@"
}
boot() {
    ./runqemu.sh >> qemu-validation.log 2>&1 &
    qemu_pid=$!
    for attempt in $(seq 1 60); do
        kill -0 "$qemu_pid"
        if guest true >/dev/null 2>&1; then
            return 0
        fi
        sleep 2
    done
    echo 'QEMU SSH startup timed out.' >&2
    return 1
}
stop_service() {
    guest '/etc/init.d/S99aesdsocket stop && test ! -e /var/tmp/aesdsocketdata && ! pidof aesdsocket'
}

file buildroot/output/target/usr/bin/aesdsocket | grep 'ARM aarch64'
test -x buildroot/output/target/etc/init.d/S99aesdsocket
boot
guest 'uname -m; pidof aesdsocket; ps | grep "[a]esdsocket -d"; test -x /usr/bin/aesdsocket'
bash assignment-autotest/test/assignment5/sockettest.sh -t 127.0.0.1
guest 'grep -F "Accepted connection from" /var/log/messages; grep -F "Closed connection from" /var/log/messages'
stop_service
guest 'grep -F "Caught signal, exiting" /var/log/messages'
stop_service
guest '/etc/init.d/S99aesdsocket start && /etc/init.d/S99aesdsocket start; test "$(pidof aesdsocket | wc -w)" -eq 1'
bash assignment-autotest/test/assignment5/sockettest.sh -t 127.0.0.1
guest 'kill -INT $(pidof aesdsocket); sleep 1; test ! -e /var/tmp/aesdsocketdata && ! pidof aesdsocket'
guest '/etc/init.d/S99aesdsocket start'
python3 - <<'PY'
import socket
with socket.create_connection(('127.0.0.1', 9000), timeout=5) as client:
    client.sendall(b'before-graceful-halt\n')
    assert client.recv(4096) == b'before-graceful-halt\n'
PY
# halt executes rcK, including S99aesdsocket stop. Resume the same disk image.
guest 'halt' || true
sleep 5
grep -F 'Stopping aesdsocket: OK' qemu-validation.log
if kill -0 "$qemu_pid" 2>/dev/null; then
    kill "$qemu_pid"
fi
wait "$qemu_pid" 2>/dev/null || true
qemu_pid=
boot
guest 'pidof aesdsocket; test ! -s /var/tmp/aesdsocketdata'
bash assignment-autotest/test/assignment5/sockettest.sh -t 127.0.0.1
stop_service
echo 'PASS: SSH, automatic startup, socket tests, signals, service restart, halt, and clean reboot.'
