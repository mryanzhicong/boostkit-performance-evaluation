#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_stream_runtime() {
    initialize_runtime || return $?
    stop_stream_vm || return $?
    log 'managed STREAM reference VM stopped'
}
