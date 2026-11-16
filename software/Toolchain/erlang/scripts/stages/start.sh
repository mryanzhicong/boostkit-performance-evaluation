#!/usr/bin/env bash
# Start stage: verify the built Erlang runtime and the compiled workload
# modules inside this task's private container.  No long-running service is
# started; "start" means "the measured workload is ready and reproducible".
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_erlang_runtime() {
    initialize_runtime || return $?
    check_erlang_container || return $?
    erlang_container_exec test -x "${BENCH_BIN}" || {
        log_message "ERROR: built runtime is missing inside the container: ${BENCH_BIN}"
        return 30
    }
    [[ -f "${PERF_ACTUAL_VERSION_FILE}" ]] || {
        log_message "ERROR: actual version file is missing: ${PERF_ACTUAL_VERSION_FILE}"
        return 30
    }
    local actual
    actual="$(cat "${PERF_ACTUAL_VERSION_FILE}")"
    [[ "${actual}" == "${SOFTWARE_VERSION}" ]] || {
        log_message "ERROR: actual version file reports ${actual}, expected ${SOFTWARE_VERSION}"
        return 30
    }
    [[ -f "${BENCH_SCENARIOS_FILE}" ]] || {
        log_message "ERROR: workload matrix manifest is missing: ${BENCH_SCENARIOS_FILE}"
        return 30
    }
    local reported
    reported="$(erlang_container_exec "${BENCH_BIN}" -noshell -eval 'io:format("~s", [erlang:system_info(otp_release)]), halt(0).' 2>/dev/null | tr -d '\n')" || reported=""
    case "${actual}" in
        "${reported}"*) ;;
        *)
            log_message "ERROR: the container runtime reports OTP ${reported}, staged version file says ${actual}"
            return 30
            ;;
    esac
    local missing=0
    local scenario dimension runner target scale check expected tolerance workload
    while IFS='|' read -r scenario dimension runner target scale check expected tolerance workload; do
        [[ -z "${scenario}" || "${scenario}" == \#* ]] && continue
        [[ "${scenario}" == "scenario" ]] && continue
        if [[ -f "${SCRIPT_DIR}/benchmarks/${target}" ]]; then
            :
        elif [[ -n "${BENCH_EBIN_DIR:-}" ]] && erlang_container_exec test -f "${BENCH_EBIN_DIR}/${target}.beam"; then
            :
        else
            log_message "ERROR: benchmark workload is missing inside the container: benchmarks/${target}"
            missing=1
        fi
    done < "${BENCH_SCENARIOS_FILE}"
    [[ "${missing}" -eq 0 ]] || return 30
    log_message "runtime check passed inside ${ERLANG_CONTAINER_NAME}: OTP ${reported}"
}
