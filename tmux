#! /usr/bin/env bash
# Find the tmux to run
IFS=':' read -ra PATH_ARRAY <<< "$PATH"
TMUX_PATH=""
for SEARCH_PATH in "${PATH_ARRAY[@]}" ; do
    TMUX_PATH=$(find $SEARCH_PATH -executable -regex '.+/tmux$' | grep --invert-match $0 | head -n1)
    if [[ $TMUX_PATH != "" ]] ; then
	break
    fi
done
if [[ $TMUX_PATH = "" ]] ; then
    echo "Could not find tmux!" 1>&2
    exit 255
fi

# Run tmux with 256 color support
exec env TERM=xterm-16color "$TMUX_PATH" -2 "$@"
