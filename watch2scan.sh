#!/bin/bash
### BEGIN INIT INFO
# Provides:          filenotifier
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: watch dir and start scan on file creation
# Description:       watch /tmp/companion dir and when a file is created with the name of a paperless type it start the scan2paperless script parameterized
### END INIT INFO
inotifywait -q -m -e create /tmp/companion | while read DIRECTORY EVENT FILE; do
if [[ ${FILE} = "auto" ]]; then
    scan2paperless
  else 
    if [[ ${FILE} = "retain" ]]; then
      scan2paperless --retain
    else
      scan2paperless --type=$FILE
    fi
  fi
done