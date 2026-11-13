#!/bin/bash
# Run a command repeatedly until it fails, to catch flaky tests.
# Usage: ./flaky.sh <command> [args...]

if [ $# -eq 0 ]; then
    echo "Usage: $0 <command> [args...]" >&2
    exit 2
fi

count=0
while "$@" > /dev/null 2>&1; do
    count=$((count + 1))
done

echo "Failed after $count successful runs: $*"