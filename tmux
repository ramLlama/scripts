#! /usr/bin/env bash
# Run tmux with 256 color support

TMUX_PATH=""
if [[ -x ~/.toast/armed/bin/tmux ]] ; then
    TMUX_PATH=~/.toast/armed/bin/tmux
elif [[ -x /usr/bin/tmux ]] ; then
    TMUX_PATH=/usr/bin/tmux
else
    echo "Could not find tmux!"
    exit 1
fi

exec env TERM=xterm-16color ${TMUX_PATH} -2 "$@"
