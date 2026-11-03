#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_scann_benchmarks() {
    initialize_runtime || return $?
    with_network_proxy "${ANN_VENV}/bin/python" "${SCRIPT_DIR}/scripts/results/run_benchmark.py" \
        --source "${ANN_ROOT}" --data "${SCANN_DATA_ROOT}" \
        --results "${RESULTS_DIR}" --wheel-version "${SOFTWARE_VERSION}" \
        --architecture "${EXPECTED_ARCH}" --image-tag "${SCANN_IMAGE_TAG}" || {
        log 'ERROR: official ann-benchmarks ScaNN matrix failed'; return 50;
    }
}
