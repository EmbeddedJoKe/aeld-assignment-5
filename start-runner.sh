#!/bin/bash
# Start only the registered Assignment 5 runner as a persistent user service.
set -euo pipefail
cd "$(dirname "$0")"
runner_dir="$PWD/actions-runner-assignment5"
test -f "$runner_dir/.runner"
unit_dir="$HOME/.config/systemd/user"
unit_file="$unit_dir/aeld-assignment5-runner.service"
mkdir -p "$unit_dir"
if [ -f "$unit_file" ] && ! grep -Fq "ExecStart=$runner_dir/run.sh" "$unit_file"; then
    echo "Refusing to replace an unrelated user service: $unit_file" >&2
    exit 1
fi
cat > "$unit_file" <<EOF
[Unit]
Description=Assignment 5 GitHub Actions runner
After=network-online.target

[Service]
WorkingDirectory=$runner_dir
ExecStart=$runner_dir/run.sh
Restart=always
RestartSec=5

[Install]
WantedBy=default.target
EOF
systemctl --user daemon-reload
systemctl --user enable --now aeld-assignment5-runner.service
systemctl --user is-active aeld-assignment5-runner.service
