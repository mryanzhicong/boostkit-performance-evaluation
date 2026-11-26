#!/usr/bin/env bash
# ==============================================================================
# Tongsuo test stage -- drive `apps/openssl speed` for every scenario.
# ==============================================================================
# Each scenario runs 1 warm-up pass and TONGSUO_SAMPLES measured passes; every
# pass is stored verbatim as runs/<scenario>/<pass>.log and the strict parser
# turns them into results.json (median) plus samples.json (all values).
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

tongsuo_run_pass() {
    local scenario="$1" kind="$2" args="$3" pass="$4" log_dir="$5" log_file
    log_file="${log_dir}/${pass}.log"
    # shellcheck disable=SC2086  # the scenario table carries deliberate argument lists
    # Options must come first: `openssl speed` treats the first positional
    # argument (and everything after it) as an algorithm name.
    if ! tongsuo_container_exec_at "${TONGSUO_SRC_DIR}" ./apps/openssl speed \
        -seconds "${TONGSUO_SECONDS}" ${args} > "${log_file}" 2>&1; then
        log_message "ERROR: scenario ${scenario} pass ${pass} failed; see ${log_file}"
        tail -n 10 "${log_file}" >&2 || true
        return 50
    fi
    if [[ ! -s "${log_file}" ]]; then
        log_message "ERROR: scenario ${scenario} pass ${pass} produced no output"
        return 50
    fi
}

run_tongsuo_benchmarks() {
    local entry scenario kind args log_dir pass
    local -a passes=()
    initialize_runtime || return $?
    check_architecture || return $?
    check_tongsuo_container || return $?
    tongsuo_verify_runtime_payload || return $?

    : > "${TONGSUO_LOG}"
    log_message "scenarios=$((${#TONGSUO_SCENARIOS[@]})) warmups=${TONGSUO_WARMUPS} samples=${TONGSUO_SAMPLES} seconds=${TONGSUO_SECONDS} statistic=${TONGSUO_STATISTIC}"

    for entry in "${TONGSUO_SCENARIOS[@]}"; do
        IFS='|' read -r scenario kind args <<< "${entry}"
        log_dir="${TONGSUO_RUNS_DIR}/${scenario}"
        rm -rf "${log_dir}"
        mkdir -p "${log_dir}"
        passes=()
        for ((pass = 1; pass <= TONGSUO_WARMUPS; pass++)); do
            passes+=("warmup${pass}")
        done
        for ((pass = 1; pass <= TONGSUO_SAMPLES; pass++)); do
            passes+=("rep${pass}")
        done
        for pass in "${passes[@]}"; do
            log_message "running ${scenario} (${pass})"
            tongsuo_run_pass "${scenario}" "${kind}" "${args}" "${pass}" "${log_dir}" || return $?
        done
        {
            printf '### scenario=%s kind=%s args=%s seconds=%s\n' \
                "${scenario}" "${kind}" "${args}" "${TONGSUO_SECONDS}"
            for pass in "${passes[@]}"; do
                printf '### pass=%s\n' "${pass}"
                cat "${log_dir}/${pass}.log"
                printf '\n'
            done
        } >> "${TONGSUO_LOG}"
    done

    log_message "parsing ${#TONGSUO_SCENARIOS[@]} scenarios strictly"
    tongsuo_container_exec python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        --runs-dir "${TONGSUO_RUNS_DIR}" \
        --results-dir "${RESULTS_DIR}" \
        --warmups "${TONGSUO_WARMUPS}" \
        --samples "${TONGSUO_SAMPLES}" \
        --version "${SOFTWARE_VERSION}" \
        --architecture "$(normalize_architecture "${EXPECTED_ARCH}")" \
        --variant "${PERF_VARIANT}" || return 50
    log_message "benchmark result written: ${RESULTS_DIR}/results.json"
}
