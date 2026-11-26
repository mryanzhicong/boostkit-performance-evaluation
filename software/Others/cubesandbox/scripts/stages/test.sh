#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_benchmark_round() {
    local level="$1" total="$2" label="$3" output="$4" logfile="$5"
    log "cube-bench concurrency=${level} total=${total} label=${label}"
    "${CUBESANDBOX_CUBE_BENCH}" \
        -c "${level}" -n "${total}" -w "${CUBESANDBOX_INNER_WARMUP}" -m create-only --no-tui \
        --api-url "${CUBESANDBOX_API_URL}" --api-key "${CUBESANDBOX_API_KEY}" \
        -t "${CUBESANDBOX_TEMPLATE_ID}" -o "${output}" >"${logfile}" 2>&1 || {
        log "ERROR: cube-bench failed for concurrency ${level} (${label})"
        tail -25 "${logfile}" || true
        return 50
    }
    [[ -s "${output}" ]] || { log "ERROR: cube-bench produced no report at ${output}"; return 50; }
}

run_cubesandbox_benchmarks() {
    initialize_runtime || return $?
    [[ -x "${CUBESANDBOX_CUBE_BENCH}" ]] || {
        log 'ERROR: cube-bench is missing; run the build stage first'; return 40
    }
    if [[ -z "${CUBESANDBOX_TEMPLATE_ID}" && -s "${RESULTS_DIR}/template_id" ]]; then
        CUBESANDBOX_TEMPLATE_ID="$(head -1 "${RESULTS_DIR}/template_id" 2>/dev/null || true)"
    fi
    [[ -n "${CUBESANDBOX_TEMPLATE_ID}" ]] || {
        log 'ERROR: no template id; run the start stage first'; return 40
    }
    local level warmup_total="${CUBESANDBOX_WARMUP_TOTAL:-100}"
    for level in ${CUBESANDBOX_LEVELS//,/ }; do
        local dir="${RESULTS_DIR}/runs/c${level}"
        mkdir -p "${dir}" || return $?
        local i
        for i in $(seq 1 "${CUBESANDBOX_WARMUPS}"); do
            run_benchmark_round "${level}" "${warmup_total}" "warmup${i}" \
                "${dir}/warmup${i}.json" "${dir}/warmup${i}.log" || return $?
            cleanup_sandboxes || return $?
        done
        for i in $(seq 1 "${CUBESANDBOX_SAMPLES}"); do
            run_benchmark_round "${level}" "${CUBESANDBOX_TOTAL}" "rep${i}" \
                "${dir}/rep${i}.json" "${dir}/rep${i}.log" || return $?
            cleanup_sandboxes || return $?
        done
        log "concurrency ${level}: ${CUBESANDBOX_WARMUPS} warmup + ${CUBESANDBOX_SAMPLES} measured rounds complete, sandboxes cleaned"
    done
    cleanup_sandboxes || return $?
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        --runs-dir "${RESULTS_DIR}/runs" \
        --results-dir "${RESULTS_DIR}" \
        --warmups "${CUBESANDBOX_WARMUPS}" \
        --samples "${CUBESANDBOX_SAMPLES}" \
        --levels "${CUBESANDBOX_LEVELS}" \
        --total "${CUBESANDBOX_TOTAL}" \
        --version "${SOFTWARE_VERSION}" \
        --architecture "${EXPECTED_ARCH}" \
        --variant "${PERF_VARIANT}" || return $?
    log "parsed metrics: ${RESULTS_DIR}/benchmark_cubesandbox.json"
}
