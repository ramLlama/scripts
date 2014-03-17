#! /usr/bin/env bash

# default init TMUX_PATH
TMUX_PATH=${TMUX_PATH:-""}

if [[ "" = $TMUX_PATH ]] ; then
    # Find the tmux to run
    IFS=':' read -ra PATH_ARRAY <<< "$PATH"
    for SEARCH_PATH in "${PATH_ARRAY[@]}" ; do
	TMUX_PATH=$(find $SEARCH_PATH -executable -regex '.+/tmux$' 2> /dev/null | grep --invert-match $0 | head -n1)
	if [[ $TMUX_PATH != "" ]] ; then
	    break
	fi
    done
    if [[ $TMUX_PATH = "" ]] ; then
	echo "Could not find tmux!" 1>&2
	exit 255
    fi
fi

# print which tmux binary I am launching
echo "Launching tmux binary at" $TMUX_PATH

# Run tmux with 256 color support
exec env TERM=xterm-16color "$TMUX_PATH" -2 "$@"
