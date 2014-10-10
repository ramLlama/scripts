#! /usr/bin/env bash

DPMS_STATUS=$(xset q | perl -ne 'if (/DPMS is (Enabled|Disabled)/) { print $1 . "\n"; }')

sendNotification () {
    notify-send --app-name="dpms-toggle.sh" --expire-time=3000 "$@"
}

if [[ $DPMS_STATUS == "Enabled" ]] ; then
    xset -dpms
    sendNotification "DPMS Disabled"
elif [[ $DPMS_STATUS == "Disabled" ]] ; then
    xset +dpms
    sendNotification "DPMS Enabled"
else
    sendNotification --urgency=critical "Could not parse 'xset q'!"
fi
