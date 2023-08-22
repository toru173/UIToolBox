#!/bin/bash
# We have to call an AppleScript here because the rename action has to
# happen through finder. That's the only way to preserve our .DS_Store
# attributes!

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

USAGE_MESSAGE="Usage: finderrename.sh PATH_TO_OLD_NAME NEW_NAME\n"
USAGE_MESSAGE+="Note: PATH_TO_OLD_NAME must be a folder"

if [ -z "$1" ]
  then
    echo ${USAGE_MESSAGE}
    exit 1
fi

if [ ! -d "$1" ]
  then
    echo ${USAGE_MESSAGE}
    exit 1
fi

if [ -z "$2" ]
  then
    echo ${USAGE_MESSAGE}
    exit 1
fi

${CURRENT_DIR}/finderrename.scpt "$1" "$2" &> /dev/null
