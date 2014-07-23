#! /usr/bin/env bash

REDSHIFT_PID=$(pidof -s redshift)

if [[ $? == 0 ]] ; then
    kill -s USR1 $REDSHIFT_PID
else
    echo "Could not find PID of redshift!" 1>&2
fi
