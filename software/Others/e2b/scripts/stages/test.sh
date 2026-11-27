#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# One sandbox-bench invocation. The tool already reports wall/ready/post split
# metrics, so the case keeps its JSON report verbatim and lets the parser do the
# cross-sample aggregation.
run_bench_round() {
    local scenario="$1" level="$2" total="$3" label="$4" output="$5" logfile="$6"
    log "sandbox-bench scenario=${scenario} concurrency=${level} requests=${total} label=${label}"
    E2B_API_URL="${E2B_API_URL}" E2B_API_KEY="${E2B_API_KEY}" E2B_TEMPLATE_ID="${E2B_TEMPLATE_ID}" \
        "${E2B_BENCH_BIN}" \
        --platform "${E2B_PLATFORM}" --scenario "${scenario}" \
        --requests "${total}" --concurrency "${level}" \
        --rounds 1 --warmup 0 \
        --output "${output}" >"${logfile}" 2>&1 || {
        log "ERROR: sandbox-bench failed for ${scenario} at concurrency ${level} (${label})"
        tail -25 "${logfile}" || true
        return 50
    }
    [[ -s "${output}" ]] || { log "ERROR: sandbox-bench produced no JSON report at ${output}"; return 50; }
}

run_e2b_benchmarks() {
    initialize_runtime || return $?
    [[ -x "${E2B_BENCH_BIN}" ]] || {
        log 'ERROR: sandbox-bench is missing; run the build stage first'; return 40
    }
    require_e2b_api_key || return $?
    if [[ -z "${E2B_TEMPLATE_ID}" && -s "${RESULTS_DIR}/template_id" ]]; then
        E2B_TEMPLATE_ID="$(head -1 "${RESULTS_DIR}/template_id" 2>/dev/null || true)"
    fi
    [[ -n "${E2B_TEMPLATE_ID}" ]] || {
        log 'ERROR: no template id; run the start stage first'; return 40
    }
    # The start stage already proved the control plane works, but a fresh Nomad
    # allocation can stay unhealthy for a few seconds (for example right after
    # the template manager recycles). Retry instead of failing on a single probe.
    local attempt
    for attempt in $(seq 1 12); do
        e2b_api_healthy && break
        sleep 5
    done
    e2b_api_healthy || { log 'ERROR: the control plane is not healthy; run the start stage first'; return 40; }
    local scenario level i
    for scenario in ${E2B_SCENARIOS//,/ }; do
        case "${scenario}" in
            create|snapshot) ;;
            *) log "ERROR: unsupported scenario: ${scenario} (create, snapshot)"; return 10 ;;
        esac
        for level in ${E2B_LEVELS//,/ }; do
            local dir="${RESULTS_DIR}/runs/${scenario}/c${level}"
            mkdir -p "${dir}" || return $?
            for i in $(seq 1 "${E2B_WARMUPS}"); do
                run_bench_round "${scenario}" "${level}" "${E2B_WARMUP_TOTAL}" "warmup${i}" \
                    "${dir}/warmup${i}.json" "${dir}/warmup${i}.log" || return $?
                cleanup_sandboxes || return $?
            done
            for i in $(seq 1 "${E2B_SAMPLES}"); do
                run_bench_round "${scenario}" "${level}" "${E2B_TOTAL}" "rep${i}" \
                    "${dir}/rep${i}.json" "${dir}/rep${i}.log" || return $?
                cleanup_sandboxes || return $?
            done
            log "${scenario} concurrency ${level}: ${E2B_WARMUPS} warmup + ${E2B_SAMPLES} measured rounds complete, sandboxes cleaned"
        done
    done
    cleanup_sandboxes || return $?
    reap_sandbox_leftovers
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        --runs-dir "${RESULTS_DIR}/runs" \
        --results-dir "${RESULTS_DIR}" \
        --warmups "${E2B_WARMUPS}" \
        --samples "${E2B_SAMPLES}" \
        --levels "${E2B_LEVELS}" \
        --scenarios "${E2B_SCENARIOS}" \
        --total "${E2B_TOTAL}" \
        --version "${SOFTWARE_VERSION}" \
        --architecture "${EXPECTED_ARCH}" \
        --variant "${PERF_VARIANT}" || return $?
    log "parsed metrics: ${RESULTS_DIR}/benchmark_e2b.json"
}
