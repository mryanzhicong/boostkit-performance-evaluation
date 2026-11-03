#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_daft_runtime() {
    configure_runtime_paths || return $?
    remove_container
}
