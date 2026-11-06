#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"
start_spark_runtime() {
    initialize_runtime || return $?
    container_exec start || return 40
}
