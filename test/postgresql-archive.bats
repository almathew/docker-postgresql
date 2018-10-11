#!/usr/bin/env bats

source "${BATS_TEST_DIRNAME}/test_helper.sh"

@test "It should archive files to the ARCHIVE_DIRECTORY" {
  mkdir -p ${DATA_DIRECTORY}/tmp
  touch ${DATA_DIRECTORY}/tmp/test.file
  /bin/bash /usr/bin/archive.sh "tmp/test.file" "test.file"
  [ -f ${ARCHIVE_DIRECTORY}/test.file ]
}

@test "It should not overwrite existing archived files" {
  mkdir -p ${DATA_DIRECTORY}/tmp
  touch ${DATA_DIRECTORY}/tmp/test.file
  touch ${ARCHIVE_DIRECTORY}/test.file
  run /bin/bash /usr/bin/archive.sh "tmp/test.file" "test.file"
  [ "$status" -eq "1" ]
}

@test "It should clean up files more than 2 days old" {
  THREE_DAYS_AGO=$(date --date="3 days ago" +"%Y%m%d%H%M")
  touch ${ARCHIVE_DIRECTORY}/old.file -t ${THREE_DAYS_AGO}
  /bin/bash /usr/bin/archive-cleanup.sh
  [ ! -f ${ARCHIVE_DIRECTORY}/old.file ]
}

@test "It should not clean up files not covered by a backup" {
  YESTERDAY=$(date --date="1 day ago" +"%Y%m%d%H%M")
  touch ${ARCHIVE_DIRECTORY}/old.file -t ${YESTERDAY}
  /bin/bash /usr/bin/archive-cleanup.sh
  [ -f ${ARCHIVE_DIRECTORY}/old.file ]
}

@test "It should have an archive command set" {
  initialize_and_start_pg
  sudo -u postgres psql db -c'SHOW archive_command;' | grep "/usr/bin/archive.sh"
}

@test "It should have have archive_mode turned on" {
  initialize_and_start_pg
  sudo -u postgres psql db -c'SHOW archive_mode;' | grep "on"
}

@test "It should not be able to read pagerduty-notify.sh as the postgres user" {
  run sudo -u postgres cat /usr/bin/pagerduty-notify.sh
  [ "$status" -eq "1" ]

}

@test "It should be able to run pagerduty-notify.sh as the postgres user" {
  HTTP_RESPONSE_HEAD='HTTP/1.1 200 OK'
  ( while echo "$HTTP_RESPONSE_HEAD" | nc -l 4443; do : ; done )  &
  sudo -u postgres sudo -u root /usr/bin/pagerduty-notify.sh
}
