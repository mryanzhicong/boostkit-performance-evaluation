#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"
run_spark_benchmarks() {
    initialize_runtime || return $?
    container_exec test || return 50
}
