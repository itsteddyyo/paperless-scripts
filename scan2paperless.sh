#!/bin/bash

hostname=$hostname
auth_token=$auth_token

retval=$(curl --retry 99 --retry-all-errors --http1.1 -f -X GET -H "Authorization: Token $auth_token" -sS https://$hostname/api/document_types/ || exit 1)
jqAvailableTypes=$(jq ".results|map(.slug)" <<<${retval})
jqAvailableIds=$(jq ".results|map(.id)" <<<${retval})
availableTypes=($(echo $jqAvailableTypes | sed -e 's/\[ //g' -e 's/\ ]//g' -e 's/\,//g'))
availableIds=($(echo $jqAvailableIds | sed -e 's/\[ //g' -e 's/\ ]//g' -e 's/\,//g'))

# More safety, by turning some bugs into errors.
# Without `errexit` you don’t need ! and can replace
# ${PIPESTATUS[0]} with a simple $?, but I prefer safety.
set -o errexit -o pipefail -o noclobber -o nounset

# -allow a command to fail with !’s side effect on errexit
# -use return value from ${PIPESTATUS[0]}, because ! hosed $?
! getopt --test >/dev/null
if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
  echo 'I’m sorry, `getopt --test` failed in this environment.'
  exit 1
fi

# option --type/-t requires 1 argument
LONGOPTS=duplex,front,retain,keep-empty,type:
OPTIONS=dfbrkt:

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

mode=Duplex identifier=$$ emptyThreshold=1 typeExtension=""
# now enjoy the options in order and nicely split until we see --
while true; do
  case "$1" in
  -d | --duplex)
    mode=Duplex
    shift
    ;;
  -f | --front)
    mode=Front
    shift
    ;;
  -b | --back)
    mode=Back
    shift
    ;;
  -r | --retain)
    identifier="retain$(date +%s)"
    shift
    ;;
  -k | --keep-empty)
    emptyThreshold=0
    shift
    ;;
  -t | --type)
    typeIndex=-1
    for i in "${!availableTypes[@]}"; do
      if [[ "${availableTypes[$i]}" = '"'"$2"'"' ]]; then
        typeIndex=$i
      fi
    done
    if [[ $2 == "auto" || $typeIndex -gt -1 ]]; then
      typeExtension="${availableIds[$typeIndex]}."
      shift 2
    else
      printf -v joined '%s,' "${availableTypes[@]}"
      echo "Type '${2}' not 'auto' or in available types ${joined%,}"
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
  echo cleanup
  if [[ $identifier -eq $$ ]]; then
    echo creating pdf
    img2pdf --pdfa --rotation=180 /tmp/s2p_retain*.png /tmp/s2p_${identifier}_*.png --output /tmp/s2p_${identifier}.${typeExtension}pdf &&
      rm -f /tmp/s2p_${identifier}_*.png

    echo starting upload
    post2paperless /tmp/s2p_${identifier}.${typeExtension}pdf &&
      rm -f /tmp/s2p_* ||
      echo upload failed, retaining file /tmp/s2p_${identifier}.${typeExtension}pdf >&2
  else
    echo retaining images for prepending to next document
  fi
}

trap 'cleanup; exit 1' EXIT

scanimage --format=png --resolution 600 --batch="/tmp/s2p_${identifier}_%d.png" --mode=Lineart --swdeskew=yes --swskip=${emptyThreshold} --batch-start=10 --source="ADF ${mode})" -x 210 -y 297
