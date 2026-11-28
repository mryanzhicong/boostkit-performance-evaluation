#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_llama_cpp_runtime() {
    initialize_runtime || return $?
    check_llama_cpp_container || return $?
    [[ -x "${LLAMA_CPP_BENCH_BIN}" ]] || {
        log "ERROR: llama-bench executable is missing: ${LLAMA_CPP_BENCH_BIN}"
        return 40
    }
    container_exec "${LLAMA_CPP_BENCH_BIN}" --help >/dev/null || {
        log 'ERROR: llama-bench failed executable check inside the managed container'
        return 40
    }
    prepare_bge_m3_model || return $?
    container_exec test -r "${LLAMA_CPP_MODEL_PATH}" || {
        log "ERROR: model is not readable inside the managed container: ${LLAMA_CPP_MODEL_PATH}"
        return 40
    }
    log "llama-cpp runtime and model are ready inside container ${LLAMA_CPP_CONTAINER_NAME}"
}
