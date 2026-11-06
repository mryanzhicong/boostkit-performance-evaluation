#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_jemalloc_runtime() {
    jemalloc_log 'benchmark container is removed by the test stage; no background service remains'
}
