#!/usr/bin/env bats

@test "It should install PostgreSQL 9.6.2" {
  run /usr/lib/postgresql/9.6/bin/postgres --version
  [[ "$output" =~ "9.6.2"  ]]
}
