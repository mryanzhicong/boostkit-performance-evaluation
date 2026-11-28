#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_llama_cpp_runtime() {
    configure_runtime_paths || return $?
    command -v docker >/dev/null 2>&1 || return 0
    remove_llama_cpp_container || return $?
    log "managed llama-cpp container stopped: ${LLAMA_CPP_CONTAINER_NAME}"
}
