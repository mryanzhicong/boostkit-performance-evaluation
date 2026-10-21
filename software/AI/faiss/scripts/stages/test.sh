#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_faiss_benchmarks() {
    if initialize_runtime; then
        :
    else
        return $?
    fi
    if ! configure_benchmark_profile; then
        return 10
    fi
    if ! python3 "${SCRIPT_DIR}/scripts/results/run_sra_benchmark.py" \
        --source "${SRA_DIR}" --data "${DATA_DIRECTORY}" \
        --results "${RESULTS_DIR}" --version "${SOFTWARE_VERSION}" \
        --architecture "$(normalize_architecture "${EXPECTED_ARCH}")" \
        --algorithms "${ACTIVE_ALGORITHMS[@]}"; then
        log_message "ERROR: sra_test Faiss benchmark failed"
        return 50
    fi
}
