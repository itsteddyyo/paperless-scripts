#!/bin/bash

hostname=$hostname
auth_token=$auth_token

retval=$(curl --retry 99 --retry-all-errors --http1.1 -f -X GET -H "Authorization: Token $auth_token" -sS https://$hostname/api/document_types/ || exit 1)
availableTypes=$(jq ".results|map(.slug)"<<<${retval})


# More safety, by turning some bugs into errors.
# Without `errexit` you don’t need ! and can replace
# ${PIPESTATUS[0]} with a simple $?, but I prefer safety.
set -o errexit -o pipefail -o noclobber -o nounset

# -allow a command to fail with !’s side effect on errexit
# -use return value from ${PIPESTATUS[0]}, because ! hosed $?
! getopt --test > /dev/null 
if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
    echo 'I’m sorry, `getopt --test` failed in this environment.'
    exit 1
fi

# option --output/-o requires 1 argument
LONGOPTS=duplex,front,back,remove-empty,type:
OPTIONS=dfbrt:

# -regarding ! and PIPESTATUS see above
# -temporarily store output to be able to check for errors
# -activate quoting/enhanced mode (e.g. by writing out “--options”)
# -pass arguments only via   -- "$@"   to separate them correctly
! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    # e.g. return value is 1
    #  then getopt has complained about wrong arguments to stdout
    exit 2
fi
# read getopt’s output this way to handle the quoting right:
eval set -- "$PARSED"

mode=Duplex emptyThreshold=0 type=auto
# now enjoy the options in order and nicely split until we see --
while true; do
    case "$1" in
        -d|--duplex)
            mode=Duplex
            shift
            ;;
        -f|--front)
            mode=Front
            shift
            ;;
        -b|--back)
            mode=Back
            shift
            ;;
        -r|--remove-empty)
            emptyThreshold=1
            shift
            ;;
        -t|--type)
            if [[ $2 == "auto" || $(echo ${availableTypes[@]} | fgrep -w $2) ]]; then
              type="$2"
              shift 2
            else
              echo "Type '${2}' not 'auto' or in available types '${availableTypes}'"
              exit 1 
            fi
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Programming error"
            exit 3
            ;;
    esac
done

cleanup() {
  echo finalizing pdf file.
  img2pdf --pdfa -rotate=180 --output /tmp/scan2paperless_${type}_$$.pdf /tmp/scan2paperless_$$_*.png && \
  rm -f /tmp/scan2paperless_$$_*.png

  post2paperless /tmp/scan2paperless_${type}_$$.pdf \
    && rm -f /tmp/scan2paperless_$$* \
    || echo upload failed, retaining file /tmp/scan2paperless_${type}_$$.pdf >&2
}

trap 'cleanup; exit 1' EXIT

scanimage --format=png --resolution 600 --batch=/tmp/scan2paperless_$$_%d.png --mode=Lineart --swdeskew=yes --swskip=${emptyThreshold} --batch-start=10 --source="ADF ${mode})" -x 210 -y 297
