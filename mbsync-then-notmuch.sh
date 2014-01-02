#! /usr/bin/env bash

# Load environment
source ${HOME}/scripts/env-bootstrap.sh

mbsync cmu
notmuch new
