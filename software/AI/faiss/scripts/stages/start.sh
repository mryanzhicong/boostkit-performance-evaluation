#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_faiss_runtime() {
    local algorithm
    if initialize_runtime; then
        :
    else
        return $?
    fi
    if ! configure_benchmark_profile; then
        return 10
    fi
    for algorithm in "${ACTIVE_ALGORITHMS[@]}"; do
        [[ -x "${SRA_DIR}/${algorithm}_test" ]] || {
            log_message "ERROR: sra_test ${algorithm} benchmark is unavailable"
            return 40
        }
    done
    log_message "sra_test Faiss C++ benchmark binaries are ready"
}
