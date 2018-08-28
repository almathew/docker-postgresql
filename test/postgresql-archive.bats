#!/usr/bin/env bats

source "${BATS_TEST_DIRNAME}/test_helper.sh"

@test "It should archive files to the ARCHIVE_DIRECTORY" {
    mkdir -p /var/db/tmp
    touch /var/db/tmp/test.file
    /bin/bash /usr/bin/archive.sh "tmp/test.file" "test.file"
    [ -f ${ARCHIVE_DIRECTORY}/test.file ]
}

@test "It should not overwrite existing archived files" {
    mkdir -p /var/db/tmp
    touch /var/db/tmp/test.file
    touch ${ARCHIVE_DIRECTORY}/test.file
    run /bin/bash /usr/bin/archive.sh "tmp/test.file" "test.file"
    [ "$status" -eq "1" ]
}

@test "It should clean up old files" {
    touch ${ARCHIVE_DIRECTORY}/old.file -t 200001011159
    /bin/bash /usr/bin/archive-cleanup.sh
    [ ! -f ${ARCHIVE_DIRECTORY}/old.file ]
}

@test "It should have an archive command set" {
    initialize_and_start_pg
    gosu postgres psql db -c'SHOW archive_command;' | grep "/usr/bin/archive.sh"
}

@test "It should have have archive_mode turned on" {
    initialize_and_start_pg
    gosu postgres psql db -c'SHOW archive_mode;' | grep "on"
}
