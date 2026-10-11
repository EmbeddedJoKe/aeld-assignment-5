#!/bin/bash
# Register only the separate Assignment 5 runner.
set -euo pipefail
cd "$(dirname "$0")"
runner_dir="$PWD/actions-runner-assignment5"
if [ ! -x "$runner_dir/config.sh" ]; then
    echo "Download and extract the GitHub Linux x64 runner into $runner_dir first." >&2
    exit 1
fi
if [ -f "$runner_dir/.runner" ]; then
    echo "The separate runner is already registered; refusing to replace it." >&2
    exit 1
fi
registration_token=$(gh api --method POST \
    repos/EmbeddedJoKe/aeld-assignment-5/actions/runners/registration-token \
    --jq .token)
cd "$runner_dir"
./config.sh --unattended \
    --url https://github.com/EmbeddedJoKe/aeld-assignment-5 \
    --token "$registration_token" \
    --name aeld-assignment-5 --labels aeld-assignment-5 --work _work
unset registration_token
