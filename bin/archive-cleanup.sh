#!/usr/bin/env bash

find $ARCHIVE_DIRECTORY/* -mtime +2 -exec rm {} \;
