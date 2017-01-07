#!/bin/bash

source $HOME/scripts/env-bootstrap.sh

while true
do
battcon.pl > /run/user/`id -u $USER`/battcon.uevent
sleep 5
done
