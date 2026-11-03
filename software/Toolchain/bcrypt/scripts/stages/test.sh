#!/usr/bin/env bash
#
# Test stage: collect every sample in a fresh Node.js process and hand the raw
# logs to the strict parser.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_one_sample() {
    local scenario="$1" mode="$2" log_path="$3" timeout_seconds
    timeout_seconds="$(scenario_timeout "${scenario}")"
    mkdir -p "$(dirname "${log_path}")"
    # The measured process is started inside the private container.  The offline
    # environment is re-asserted there explicitly because `docker exec` does not
    # inherit the host stage environment.
    local -a measured_env=(
        env
        "UV_THREADPOOL_SIZE=1" "TZ=UTC" "LANG=C" "LC_ALL=C" "NODE_ENV=production"
        "HOME=${BCRYPT_CONTAINER_HOME}" "TMPDIR=${TMPDIR:-/tmp}" "DEBUGINFOD_URLS="
        "http_proxy=http://127.0.0.1:9" "https_proxy=http://127.0.0.1:9"
        "HTTP_PROXY=http://127.0.0.1:9" "HTTPS_PROXY=http://127.0.0.1:9"
        "no_proxy=" "NO_PROXY="
    )
    if ! bcrypt_container_exec "${measured_env[@]}" \
        timeout --signal=TERM --kill-after=10 "${timeout_seconds}" \
        "${NODE_BIN}" "${SCRIPT_DIR}/fixtures/bcrypt_runner.js" \
        --scenarios "${SCENARIOS_FILE}" --scenario "${scenario}" --mode "${mode}" \
        --module-dir "${APP_DIR}/node_modules" >"${log_path}" 2>&1; then
        local status=$?
        log_message "ERROR: ${scenario} (${mode}) failed with exit ${status}"
        tail -n 20 "${log_path}" >&2 || true
        return 50
    fi
    if ! grep -q '^\[bcrypt-bench\] ' "${log_path}"; then
        log_message "ERROR: ${scenario} (${mode}) produced no evidence line"
        tail -n 20 "${log_path}" >&2 || true
        return 50
    fi
}

run_bcrypt_benchmarks() {
    initialize_runtime || return $?
    check_bcrypt_container || return $?
    bcrypt_measurement_env || return $?
    validate_reps || return $?
    bcrypt_container_exec test -x "${NODE_BIN}" || {
        log_message "ERROR: Node.js runtime is missing; run the build stage first"; return 50; }
    local measurement_log="${RESULTS_DIR}/measurement.log"
    : >"${measurement_log}"
    local scenario index
    for scenario in "${BCRYPT_SCENARIOS[@]}"; do
        mkdir -p "${RUNS_DIR}/${scenario}"
        if [[ "${BCRYPT_WARMUPS}" -gt 0 ]]; then
            log_message "warmup: ${scenario}"
            run_one_sample "${scenario}" prefetch "${RUNS_DIR}/${scenario}/warmup.log" || {
                log_message "ERROR: warm-up failed for ${scenario}"; return 50; }
            grep '^\[bcrypt-bench\] ' "${RUNS_DIR}/${scenario}/warmup.log" | tee -a "${measurement_log}" >/dev/null || true
        fi
        for index in $(seq 1 "${BCRYPT_REPS}"); do
            log_message "sample ${index}/${BCRYPT_REPS}: ${scenario}"
            run_one_sample "${scenario}" measure "${RUNS_DIR}/${scenario}/rep${index}.log" || {
                log_message "ERROR: sample ${index} failed for ${scenario}"; return 50; }
            grep '^\[bcrypt-bench\] ' "${RUNS_DIR}/${scenario}/rep${index}.log" | tee -a "${measurement_log}" >/dev/null || true
        done
    done
    log_message "measurement finished (${#BCRYPT_SCENARIOS[@]} scenarios x ${BCRYPT_REPS} samples)"
    export PERF_REPS="${BCRYPT_REPS}"
    if ! python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" "${RUNS_DIR}" "${RESULTS_DIR}/results.json"; then
        log_message "ERROR: strict result parsing failed"
        if [[ -f "${measurement_log}" ]]; then
            tail -n 40 "${measurement_log}" >&2 || true
        fi
        return 50
    fi
    log_message "results written to ${RESULTS_DIR}/results.json"
}
