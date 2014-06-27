#! /usr/bin/env bash

DIRECTORY="$1"
INTERVAL="$2"

feh --randomize --bg-fill --no-xinerama "$DIRECTORY"
while [[ $? = 0 ]] ; do
    sleep "$INTERVAL"
    feh --randomize --bg-fill --no-xinerama "$DIRECTORY"
done
