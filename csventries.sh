#! /usr/bin/env bash

FILE="$1"
SKIP_HEADER=false

# Parse arguments
for arg in "$@"; do
    if [ "$arg" = "--has-header" ]; then
        SKIP_HEADER=true
    elif [ -f "$arg" ]; then
        FILE="$arg"
    fi
done

# Process the file
{
    if [ "$SKIP_HEADER" = true ]; then
        tail -n +2 "$FILE"
    else
        cat "$FILE"
    fi
} | sed 's/#.*//' | grep -v '^[[:space:]]*$'
