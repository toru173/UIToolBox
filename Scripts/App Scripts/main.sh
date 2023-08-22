#!/bin/bash

BIN_PATH="${BASH_SOURCE:-$0}"
DIR_PATH=${BIN_PATH%/*}

APP_NAME="Example App"

SAVE="$DIR_PATH"/save
OPEN="$DIR_PATH"/open
ALERT="$DIR_PATH"/alert

"$ALERT" "$APP_NAME" "Hello World!"
