#!/usr/bin/env bash
# Run the full bdevperf measurement matrix inside the private container and apply
# the strict parser on the host.
#
# Everything below runs offline: the proxies are removed from the environment and
# the parser never downloads anything.  The container only drives bdevperf and
# records raw logs plus GNU time artifacts; the host-side `report` step turns
# those artifacts into metrics and rejects any missing sample, non-numeric value
# or non-zero bdevperf exit with exit code 50.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_spdk_benchmarks() {
    initialize_runtime || return $?
    check_spdk_container || return $?
    spdk_container_exec test -x "${BDEVPERF_BIN}" || {
        log_message 'ERROR: bdevperf is missing in the container; run the build stage first'
        return 50
    }
    spdk_container_exec test -x /usr/bin/time || {
        log_message 'ERROR: GNU time is missing in the container'
        return 50
    }
    if [[ ! -s "${RUNTIME_PROFILE_FILE}" ]]; then
        log_message 'ERROR: the DPDK runtime profile is missing; run the start stage first'
        return 50
    fi
    if [[ ! -s "${BUILD_META_FILE}" ]]; then
        log_message 'ERROR: the build metadata is missing; run the build stage first'
        return 50
    fi
    unset http_proxy https_proxy all_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY PERF_PROXY
    log_message "driving the bdevperf matrix in the container: ${SPDK_WARMUP_REPS} warmup + ${SPDK_MEASUREMENT_REPS} measurement reps per scenario, ${SPDK_DURATION_SECONDS}s each"
    local -a measurement_args=(
        --bdevperf "${BDEVPERF_BIN}"
        --work-dir "${PERF_WORK_DIR}"
        --results-dir "${RESULTS_DIR}"
        --version "${SOFTWARE_VERSION}"
        --architecture "$(normalize_architecture "${EXPECTED_ARCH}")"
        --variant "${PERF_VARIANT}"
        --reps "${SPDK_MEASUREMENT_REPS}"
        --warmup "${SPDK_WARMUP_REPS}"
        --duration "${SPDK_DURATION_SECONDS}"
    )
    spdk_container_exec_at "${PERF_WORK_DIR}" \
        env LC_ALL=C LANG=C TZ=UTC \
        python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" drive \
        "${measurement_args[@]}" || {
        log_message 'ERROR: the bdevperf drive phase failed inside the container'
        return 50
    }
    log_message 'bdevperf matrix recorded; applying the strict parser on the host'
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" report \
        "${measurement_args[@]}" || {
        log_message 'ERROR: the bdevperf measurement matrix failed strict validation'
        return 50
    }
    log_message 'bdevperf matrix finished'
}
