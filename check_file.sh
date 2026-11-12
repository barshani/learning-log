#!/bin/bash
# Check whether the file given as the first argument exists.

if [ $# -ne 1 ]; then
    echo "Usage: $0 <file>" >&2
    exit 2
fi

if [ -f "$1" ]; then
    echo "$1 exists"
    exit 0
else
    echo "$1 does not exist" >&2
    exit 1
fi