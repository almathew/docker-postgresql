#!/usr/bin/env bash

set -e

PATH_TO_FILE=$1
WAL_FILE_NAME=$2
EVENT_ENDPOINT='https://events.pagerduty.com/generic/2010-04-15/create_event.json'

notify () {
  sudo -u root /usr/bin/pagerduty-notify.sh
}

trap 'notify' ERR

test ! -f $ARCHIVE_DIRECTORY/$WAL_FILE_NAME
cp $DATA_DIRECTORY/$PATH_TO_FILE $ARCHIVE_DIRECTORY/$WAL_FILE_NAME
/bin/bash archive-cleanup.sh