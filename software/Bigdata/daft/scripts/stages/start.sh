#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_daft_runtime() {
    initialize_runtime || return $?
    check_container || return $?
    [[ -x "${DAFT_VENV}/bin/python" ]] || { log 'ERROR: private Daft environment missing'; return 40; }
    [[ -d "${DAFT_PARQUET}" && -s "${DAFT_MANIFEST}" ]] || {
        log 'ERROR: TPC-H Parquet data and checksum manifest must be staged before testing'; return 40;
    }
}
