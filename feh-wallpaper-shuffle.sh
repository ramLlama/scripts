#! /usr/bin/env bash

###########
# Globals #
###########
SCALE_THRESHOLD='0.2'

#############
# Arguments #
#############
DIRECTORY="$1"
INTERVAL="$2"
DEBUG_FILENAME=0
if [[ $# -gt 2 ]] ; then
    DEBUG_FILENAME="$3"
fi

function errcho {
    >&2 "$@"
}

while true ; do
    XRANDR_LINE=$(xrandr | head -n 1)
    if [[ $? != 0 ]] ; then
	if [[ $DEBUG_FILENAME != 0 ]] ; then
	    errcho "Could not get xrandr!"
	fi
	exit 1
    fi

    DISPLAY_WIDTH=$(perl -e "\$_ = '$XRANDR_LINE'; if (/current (\d+) x \d+/) { print \$1 . \"\n\"; } else { exit 1; }")
    if [[ $? != 0 ]] ; then
	if [[ $DEBUG_FILENAME != 0 ]] ; then
	    errcho "Could not parse display width!"
	fi
	exit 1
    fi

    DISPLAY_HEIGHT=$(perl -e "\$_ = '$XRANDR_LINE'; if (/current \d+ x (\d+)/) { print \$1 . \"\n\"; } else { exit 1; }")
    if [[ $? != 0 ]] ; then
	if [[ $DEBUG_FILENAME != 0 ]] ; then
	    errcho "Could not parse display height!"
	fi
    	exit 1
    fi

    if [[ $DEBUG_FILENAME = 0 ]] ; then
	CANDIDATE=$(find -L "$DIRECTORY" -type f | shuf --head-count=1)
	if [[ $? != 0 ]] ; then
    	    exit 1
	fi
    else
	CANDIDATE="$DEBUG_FILENAME"
    fi

    CONVERT_LINE=$(convert "$CANDIDATE" -print "%w x %h\n" /dev/null)

    CANDIDATE_WIDTH=$(perl -e "\$_ = '$CONVERT_LINE'; if (/(\d+) x \d+/) { print \$1 . \"\n\"; } else { exit 1; }")
    if [[ $? != 0 ]] ; then
	if [[ $DEBUG_FILENAME != 0 ]] ; then
	    errcho "Could not get candidate width!"
	fi
    	exit 1
    fi

    CANDIDATE_HEIGHT=$(perl -e "\$_ = '$CONVERT_LINE'; if (/\d+ x (\d+)/) { print \$1 . \"\n\"; } else { exit 1; }")
    if [[ $? != 0 ]] ; then
	if [[ $DEBUG_FILENAME != 0 ]] ; then
	    errcho "Could not get candidate height!"
	fi
    	exit 1
    fi

    SCALE_DOWN=$(echo "scale=2;" \
		 "(($DISPLAY_HEIGHT - $CANDIDATE_HEIGHT) < 0) ||" \
    		 "(($DISPLAY_WIDTH - $CANDIDATE_WIDTH) < 0)" | bc)
    if [[ $? != 0 ]] ; then
	if [[ $DEBUG_FILENAME != 0 ]] ; then
	    errcho "Could not calculate SCALE_DOWN!"
	fi
    	exit 1
    fi

    SCALE_UP=$(echo "scale=2;" \
			"((($DISPLAY_HEIGHT - $CANDIDATE_HEIGHT) /" \
    			"$CANDIDATE_HEIGHT) < $SCALE_THRESHOLD) &&" \
    			"((($DISPLAY_WIDTH - $CANDIDATE_WIDTH) /" \
    			"$CANDIDATE_WIDTH) < $SCALE_THRESHOLD)" | bc)
    if [[ $? != 0 ]] ; then
	if [[ $DEBUG_FILENAME != 0 ]] ; then
	    errcho "Could not calculate SCALE_UP!"
	fi
    	exit 1
    fi

    if [[ $SCALE_DOWN = 1 || $SCALE_UP = 1 ]] ; then
	feh --bg-max --no-xinerama "$CANDIDATE"
	if [[ $? != 0 ]] ; then
	    if [[ $DEBUG_FILENAME != 0 ]] ; then
		errcho "Failed to call 'feh --bg-max --no-xinerama "$CANDIDATE"'!"
	    fi
    	    exit 1
	fi
    else
	feh --bg-center --no-xinerama "$CANDIDATE"
	if [[ $? != 0 ]] ; then
	    if [[ $DEBUG_FILENAME != 0 ]] ; then
		errcho "Failed to call 'feh --bg-center --no-xinerama "$CANDIDATE"'!"
	    fi
    	    exit 1
	fi
    fi

    if [[ $DEBUG_FILENAME != 0 ]] ; then
	echo $XRANDR_LINE
	echo $DISPLAY_WIDTH
	echo $DISPLAY_HEIGHT
	echo $CANDIDATE
	echo $CONVERT_LINE
	echo $CANDIDATE_WIDTH
	echo $CANDIDATE_HEIGHT

	echo "scale=2;" \
	     "(($DISPLAY_HEIGHT - $CANDIDATE_HEIGHT) < 0) ||" \
    	     "(($DISPLAY_WIDTH - $CANDIDATE_WIDTH) < 0)"
	echo "SCALE_DOWN = $SCALE_DOWN"
	echo "scale=2;" \
	     "((($DISPLAY_HEIGHT - $CANDIDATE_HEIGHT) /" \
    	     "$CANDIDATE_HEIGHT) < $SCALE_THRESHOLD) &&" \
    	     "((($DISPLAY_WIDTH - $CANDIDATE_WIDTH) /" \
    	     "$CANDIDATE_WIDTH) < $SCALE_THRESHOLD)"
	echo "SCALE_UP = $SCALE_UP"
    fi

    sleep "$INTERVAL"
done
