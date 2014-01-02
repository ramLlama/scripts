#! /usr/bin/env sh
# Run tmux with 256 color support
exec env TERM=xterm-16color /usr/bin/tmux -2 "$@"
