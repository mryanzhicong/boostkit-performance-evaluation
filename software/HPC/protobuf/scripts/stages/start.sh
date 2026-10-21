#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_protobuf_runtime() {
    initialize_runtime || return $?
    if [[ ! -x "${PROTOC_BIN}" ]]; then
        log_message "ERROR: private protoc is unavailable: ${PROTOC_BIN}"
        return 40
    fi
    if [[ ! -x "${BENCHMARK_BIN}" ]]; then
        log_message "ERROR: original protobuf-benchmark binary is unavailable"
        return 40
    fi
    if [[ ! -x "${FIXTURE_DUMP_BIN}" ]]; then
        log_message "ERROR: protobuf fixture generator is unavailable"
        return 40
    fi
    log_message "protobuf runtime is ready"
}
