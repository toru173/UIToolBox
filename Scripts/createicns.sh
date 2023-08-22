#!/bin/bash

USAGE_MESSAGE="Usage: createicns.sh PATH_TO_1024x1024_IMAGE PATH_TO_OUTPUT"

if [ -z "$1" ]
  then
    echo ${USAGE_MESSAGE}
    exit 1
fi

if [ -z "$2" ]
  then
    echo ${USAGE_MESSAGE}
    exit 1
fi

FILEPATH="$1"
OUTPUT="$2"

# https://stackoverflow.com/a/20703594
mkdir "${OUTPUT}"/.AppIcon.iconset

sips --resampleWidth 16 "${FILEPATH}" --out "${OUTPUT}"/.AppIcon.iconset/icon_16x16.png &> /dev/null
sips --resampleWidth 32 "${FILEPATH}" --out "${OUTPUT}"/.AppIcon.iconset/icon_16x16@2x.png &> /dev/null

sips --resampleWidth 32 "${FILEPATH}" --out "${OUTPUT}"/.AppIcon.iconset/icon_32x32.png &> /dev/null
sips --resampleWidth 64 "${FILEPATH}" --out "${OUTPUT}"/.AppIcon.iconset/icon_32x32@2x.png &> /dev/null

sips --resampleWidth 128 "${FILEPATH}" --out "${OUTPUT}"/.AppIcon.iconset/icon_128x128.png &> /dev/null
sips --resampleWidth 256 "${FILEPATH}" --out "${OUTPUT}"/.AppIcon.iconset/icon_128x128@2x.png &> /dev/null

sips --resampleWidth 256 "${FILEPATH}" --out "${OUTPUT}"/.AppIcon.iconset/icon_256x256.png &> /dev/null
sips --resampleWidth 512 "${FILEPATH}" --out "${OUTPUT}"/.AppIcon.iconset/icon_256x256@2x.png &> /dev/null

sips --resampleWidth 512 "${FILEPATH}" --out "${OUTPUT}"/.AppIcon.iconset/icon_512x512.png &> /dev/null
sips --resampleWidth 1024 "${FILEPATH}" --out "${OUTPUT}"/.AppIcon.iconset/icon_512x512@2x.png &> /dev/null

iconutil -c icns "${OUTPUT}"/.AppIcon.iconset -o "${OUTPUT}"/AppIcon.icns
rm -rf "${OUTPUT}"/.AppIcon.iconset
