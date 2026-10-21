#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_golang_runtime() {
    initialize_runtime || return $?
    configure_go_environment
    verify_golang_binary || return $?
    mkdir -p "${PERF_WORK_DIR}/smoke"
    printf 'package main\nfunc main() {}\n' > "${PERF_WORK_DIR}/smoke/main.go"
    if ! (
        cd "${PERF_WORK_DIR}/smoke"
        "${GO_BIN}" build -o smoke main.go
        ./smoke
    ); then
        log_message "ERROR: installed Go binary failed its smoke build"
        return 40
    fi
}
