#!/bin/bash

USAGE_MESSAGE="Usage: createuiassets.sh PATH_TO_1024x1024_IMAGES_FOLDER PATH_TO_OUTPUT 1X_SIZE_(PIXELS)"

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

if [ -z "$3" ]
  then
    echo ${USAGE_MESSAGE}
    exit 1
    # https://stackoverflow.com/a/806923
    re='^[0-9]+$'
    if ! [[ "$3" =~ $re ]] ; then
        echo ${USAGE_MESSAGE}
        exit 1
    fi
fi


FILEPATH="$1"
OUTPUT="$2"
BASE_SIZE="$3"

# https://www.cyberciti.biz/tips/handling-filenames-with-spaces-in-bash.html
# save and change IFS
OLDIFS=$IFS
IFS=$'\n'

FILES=($(find "${FILEPATH}" -type f -name "*.png" -maxdepth 1))

# restore it
IFS=$OLDIFS

if [[ ! -d "${OUTPUT}/Assets" ]]; then
    mkdir "${OUTPUT}/Assets"
fi

for i in "${FILES[@]}"
do
    FILENAME=${i##*/}
    BASEFILENAME=${FILENAME%%.*}
    sips -s format tiff --resampleWidth ${BASE_SIZE} "${i}" --out "${OUTPUT}"/Assets/"${BASEFILENAME}".tiff &> /dev/null
    sips -s format tiff --resampleWidth $((${BASE_SIZE} * 2)) "${i}" --out "${OUTPUT}"/Assets/"${BASEFILENAME}"@2x.tiff &> /dev/null
    
    tiffutil -cathidpicheck "${OUTPUT}"/Assets/"${BASEFILENAME}".tiff "${OUTPUT}"/Assets/"${BASEFILENAME}"@2x.tiff -out "${OUTPUT}"/Assets/"${BASEFILENAME}".tiff &> /dev/null
    rm "${OUTPUT}"/Assets/"${BASEFILENAME}"@2x.tiff
done

# Strip any whitespace
for f in "${OUTPUT}"/Assets/*
do
    mv "$f" `echo $f | tr -d ' '`
done
