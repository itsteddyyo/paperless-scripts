#!/bin/bash
hostname=$hostname
auth_token=$auth_token

postdoc() {
  while [[ $# -gt 0 ]]; do
    data="@${1}"
    retval=$(curl --retry 99 --retry-all-errors --http1.1 -f -X POST -H "Authorization: Token $auth_token" --form "document=$data" -sS https://$hostname/api/documents/post_document/ || exit 1)
    if [[ $? -gt 0 ]]; then
      echo "curl failed, see error message above."
      exit 1
    fi
    if [[ "$retval" == \"OK\" ]]; then
      echo "WARNING: posting data was successful. This does not mean the file was properly imported. Do your checks before deleting data" >&2
      shift
    else
      # see if this is a uuid we can query the task api with
      # make a little loop until the document was properly ingested by paperless
      status="unknown"
      while [[ $status != "SUCCESS" ]] && [[ ${status} != "FAILURE" ]]; do

        taskinfo=$(curl --retry 99 --retry-all-errors --http1.1 -f -X GET -H "Authorization: Token $auth_token" -sS https://${hostname}/api/tasks/?task_id=${retval//\"/})
        status=$(jq -r .[].status <<<${taskinfo})

        if [[ ${status} == "SUCCESS" ]]; then
          echo "Document uploaded as https://${hostname}/documents/$(jq -r .[].related_document <<<$taskinfo)"
          shift
        elif [[ ${status} == "FAILURE" ]]; then
          echo "failed to upload document $data"
          jq -r .[].result <<<$taskinfo
          exit 1
        else
          # echo "DEBUG: waiting while task ${retval} is being executed"
          sleep 1
        fi
      done
    fi
  done
}

if [[ $# -eq 0 ]]; then
  postdoc "-"
else
  postdoc "$@"
fi
