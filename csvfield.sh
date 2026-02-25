#! /usr/bin/env bash

ENTRY=$1
FIELD=$2

echo "$ENTRY" | cut -d, "-f$FIELD"
