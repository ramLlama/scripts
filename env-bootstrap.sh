#! /usr/bin/env false

# This script bootstraps the various environment variables to the
# custom ones for me. DO NOT RUN THIS FILE! Source it instead to
# import the various environment variable changes

# Make sure SHELL is set correctly
SHELL=/bin/bash

# Constants
TOAST_LOCATION=${HOME}/.toast/armed/bin/toast

# The temp file for this script
TEMP_FILE=$(mktemp)

# Load toast environment
if [[ -x $TOAST_LOCATION ]] ;
then
    ${TOAST_LOCATION} env > "${TEMP_FILE}"
    source "${TEMP_FILE}"
fi

# Load cabal environment
PATH=~/.cabal/bin:${PATH}

# Load Custom scripts and bin directory
PATH=${HOME}/scripts:${HOME}/bin:${PATH}

# load perl environment
perl -Mlocal::lib > "${TEMP_FILE}"
source "${TEMP_FILE}"

# Remove temp file
rm $TEMP_FILE
