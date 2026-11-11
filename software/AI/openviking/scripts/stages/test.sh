#!/usr/bin/env bash
# Test stage: execute the OpenViking v0.5.0 benchmark-kit protocol inside the
# private container and publish the strict metric contract.
#
#   1. warm-up pass: the first LoCoMo session is written and the 152 search
#      questions are replayed against a discarded workspace, so first-touch
#      effects (module import, database/vector-index creation, provider
#      handshake) never land in the measured evidence;
#   2. measured pass: the complete seven-step kit protocol runs on a fresh
#      workspace -- 61 write commits with per-stage telemetry, 152 search
#      questions, 152 QA questions, instrumentation coverage, report suite;
#   3. the host parser turns the raw kit telemetry into the repository metric
#      contract (medians over every per-item sample, all samples retained).
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/start.sh"

prepare_openviking_pass_dirs() {
    local run_root="$1"
    openviking_run "mkdir -p '${run_root}/raw' '${run_root}/metrics' '${run_root}/logs' \
        '${run_root}/reports' '${run_root}/result' '${run_root}/workspace'" || return 50
    openviking_run "cp '${OPENVIKING_KIT_DIR}/data/locomo10.json' '${run_root}/raw/locomo10.json'" || return 50
}

run_openviking_warmup_pass() {
    local warm="${OPENVIKING_WARMUP_RUN_ROOT}"
    log_message "warm-up pass: discarded evidence in ${warm}"
    prepare_openviking_pass_dirs "${warm}" || return $?
    prepare_openviking_config "${warm}" || return $?
    start_openviking_server "${warm}" "${warm}/ov.conf" || return $?
    if ! openviking_run "env RUN_ROOT='${warm}' bash '${SCRIPT_DIR}/benchmark/run_protocol.sh' warmup"; then
        log_message "WARNING: the warm-up protocol pass failed; continuing with the measured pass"
    fi
    stop_openviking_server
    log_message "warm-up pass finished"
}

run_openviking_measured_pass() {
    local run="${OPENVIKING_RUN_ROOT}" protocol_status=0
    log_message "measured pass: full seven-step benchmark-kit protocol in ${run}"
    prepare_openviking_pass_dirs "${run}" || return $?
    prepare_openviking_config "${run}" || return $?
    start_openviking_server "${run}" "${run}/ov.conf" || return $?
    if ! openviking_run "bash '${SCRIPT_DIR}/benchmark/run_protocol.sh' full"; then
        protocol_status=50
    fi
    return "${protocol_status}"
}

publish_openviking_reports() {
    local run="${OPENVIKING_RUN_ROOT}"
    mkdir -p "${RESULTS_DIR}/reports" || return 60
    cp -a "${run}/reports/." "${RESULTS_DIR}/reports/" 2>/dev/null || true
    if [[ -f "${run}/metrics/instrumentation_coverage.json" ]]; then
        cp "${run}/metrics/instrumentation_coverage.json" "${RESULTS_DIR}/reports/" || true
    fi
    if [[ -f "${run}/metrics/env_info.json" ]]; then
        cp "${run}/metrics/env_info.json" "${RESULTS_DIR}/reports/" || true
    fi
    if ! find "${RESULTS_DIR}/reports" -type f | grep -q .; then
        log_message "ERROR: the report output directory is empty"
        return 60
    fi
}

parse_openviking_results() {
    local source_commit kit_sha256
    source_commit=""
    kit_sha256=""
    [[ -f "${RESULTS_DIR}/source-commit.txt" ]] && source_commit="$(tr -d '[:space:]' < "${RESULTS_DIR}/source-commit.txt")"
    [[ -f "${RESULTS_DIR}/kit-sha256.txt" ]] && kit_sha256="$(tr -d '[:space:]' < "${RESULTS_DIR}/kit-sha256.txt")"
    if ! python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        --run-root "${OPENVIKING_RUN_ROOT}" \
        --output "${RESULTS_DIR}/benchmark_openviking.json" \
        --runs "${RESULTS_DIR}/runs" \
        --software-version "${SOFTWARE_VERSION}" \
        --architecture "${OPENVIKING_ARCH}" \
        --run-id "${PERF_RUN_ID}" \
        --variant "${PERF_VARIANT}" \
        --source-commit "${source_commit}" \
        --kit-sha256 "${kit_sha256}" \
        --kit-archive "${OPENVIKING_KIT_ARCHIVE_NAME}" \
        --mock-model "${OPENVIKING_MOCK_MODEL}" \
        --mock-embedding-model "${OPENVIKING_MOCK_EMBEDDING_MODEL}"; then
        log_message "ERROR: the benchmark-kit telemetry could not be parsed"
        return 50
    fi
}

run_openviking_benchmarks() {
    local protocol_status=0
    initialize_runtime || return $?
    check_openviking_container || return $?
    if ! wait_for_openviking_http "http://127.0.0.1:${OPENVIKING_MOCK_PORT}/health" 30; then
        log_message "ERROR: the provider mock is not healthy; rerun the start stage"
        return 50
    fi
    run_openviking_warmup_pass || return $?
    if ! run_openviking_measured_pass; then
        protocol_status=50
    fi
    stop_openviking_server
    publish_openviking_reports || return $?
    parse_openviking_results || return $?
    log_message "measured pass published: ${RESULTS_DIR}/benchmark_openviking.json (protocol_status=${protocol_status})"
    return "${protocol_status}"
}
