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

# feh --randomize --bg-fill --no-xinerama "$DIRECTORY"
# while [[ $? = 0 ]] ; do
#     sleep "$INTERVAL"
#     feh --randomize --bg-fill --no-xinerama "$DIRECTORY"
# done

while true ; do
    XRANDR_LINE=$(xrandr | head -n 1)
    if [[ $? != 0 ]] ; then
	exit 1
    fi

    DISPLAY_WIDTH=$(perl -e "\$_ = '$XRANDR_LINE'; if (/current (\d+) x \d+/) { print \$1 . \"\n\"; } else { exit 1; }")
    if [[ $? != 0 ]] ; then
	exit 1
    fi

    DISPLAY_HEIGHT=$(perl -e "\$_ = '$XRANDR_LINE'; if (/current \d+ x (\d+)/) { print \$1 . \"\n\"; } else { exit 1; }")
    if [[ $? != 0 ]] ; then
    	exit 1
    fi

    if [[ $DEBUG_FILENAME = 0 ]] ; then
	CANDIDATE=$(find "$DIRECTORY" -type f | shuf --head-count=1)
	if [[ $? != 0 ]] ; then
    	    exit 1
	fi
    else
	CANDIDATE="$DEBUG_FILENAME"
    fi

    CONVERT_LINE=$(convert "$CANDIDATE" -print "%w x %h\n" /dev/null)

    CANDIDATE_WIDTH=$(perl -e "\$_ = '$CONVERT_LINE'; if (/(\d+) x \d+/) { print \$1 . \"\n\"; } else { exit 1; }")
    if [[ $? != 0 ]] ; then
    	exit 1
    fi

    CANDIDATE_HEIGHT=$(perl -e "\$_ = '$CONVERT_LINE'; if (/\d+ x (\d+)/) { print \$1 . \"\n\"; } else { exit 1; }")
    if [[ $? != 0 ]] ; then
    	exit 1
    fi

    SCALE=$(echo "scale=2;" \
		 "((($DISPLAY_HEIGHT - $CANDIDATE_HEIGHT) /" \
    		   "$CANDIDATE_HEIGHT) < $SCALE_THRESHOLD) &&" \
    		 "((($DISPLAY_WIDTH - $CANDIDATE_WIDTH) /" \
    		   "$CANDIDATE_WIDTH) < $SCALE_THRESHOLD)" | bc)
    if [[ $? != 0 ]] ; then
    	exit 1
    fi

    if [[ $SCALE = 1 ]] ; then
	feh --bg-fill --no-xinerama "$CANDIDATE"
	if [[ $? != 0 ]] ; then
    	    exit 1
	fi
    else
	feh --bg-center --no-xinerama "$CANDIDATE"
	if [[ $? != 0 ]] ; then
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
	     "((($DISPLAY_HEIGHT - $CANDIDATE_HEIGHT) /" \
    	     "$CANDIDATE_HEIGHT) < $SCALE_THRESHOLD) &&" \
    	     "((($DISPLAY_WIDTH - $CANDIDATE_WIDTH) /" \
    	     "$CANDIDATE_WIDTH) < $SCALE_THRESHOLD)"
	echo "SCALE = $SCALE"
    fi

    sleep "$INTERVAL"
done
