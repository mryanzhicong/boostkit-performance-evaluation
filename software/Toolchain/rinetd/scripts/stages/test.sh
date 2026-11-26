#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

RINETD_PORTS_FILE="${RESULTS_DIR}/ports.env"
RINETD_PIDFILE="${RESULTS_DIR}/rinetd.pid"
SERVER_PID=""
SERVER_PIDFILE=""

load_ports() {
    [[ -f "${RINETD_PORTS_FILE}" ]] || {
        log_message "ERROR: missing port file from the start stage: ${RINETD_PORTS_FILE}"
        return 50
    }
    # shellcheck disable=SC1090
    source "${RINETD_PORTS_FILE}"
}

# A backgrounded in-container helper is reparented to the container's init
# process (``sleep infinity``), which never reaps it; a finished helper therefore
# stays visible as a zombie and ``kill -0`` keeps succeeding.  Treat zombies as
# exited, otherwise the stop/test stages would wait forever.
container_pid_alive() {
    local pid="$1"
    [[ "${pid}" =~ ^[0-9]+$ ]] || return 1
    rinetd_container_exec sh -c "
        kill -0 '${pid}' 2>/dev/null || exit 1
        state=\$(sed -n 's/^State:[[:space:]]*//p' /proc/'${pid}'/status 2>/dev/null)
        [ \"\${state%% *}\" != Z ]
    " >/dev/null 2>&1
}

stop_server() {
    if container_pid_alive "${SERVER_PID}"; then
        rinetd_container_exec sh -c "kill -TERM ${SERVER_PID}" >/dev/null 2>&1 || true
        for _ in $(seq 1 40); do
            container_pid_alive "${SERVER_PID}" || break
            sleep 0.02
        done
        rinetd_container_exec sh -c "kill -KILL ${SERVER_PID}" >/dev/null 2>&1 || true
    fi
    SERVER_PID=""
    if [[ -n "${SERVER_PIDFILE}" ]]; then
        rm -f -- "${SERVER_PIDFILE}"
        SERVER_PIDFILE=""
    fi
}

wait_for_server() {
    local log_file="$1" timeout_ticks=500 tick
    for tick in $(seq 1 "${timeout_ticks}"); do
        if grep -q '^LISTENING ' "${log_file}" 2>/dev/null; then
            return 0
        fi
        if [[ -n "${SERVER_PID}" ]] && ! container_pid_alive "${SERVER_PID}"; then
            log_message "ERROR: server process exited before listening"
            tail -n 40 -- "${log_file}" | while IFS= read -r line; do log_message "  ${line}"; done
            return 1
        fi
        sleep 0.02
    done
    log_message "ERROR: server did not start listening in time"
    tail -n 40 -- "${log_file}" | while IFS= read -r line; do log_message "  ${line}"; done
    return 1
}

# Starts the per-sample backend server inside the private container, writes its
# pid to a host-visible pid file and records the pid for the cleanup trap.
start_server() {
    local server_log="$1"
    shift
    SERVER_PIDFILE="${server_log%.log}.pid"
    rm -f -- "${SERVER_PIDFILE}"
    rinetd_container_exec sh -c \
        "setsid '${RINETD_BENCH_BIN}' $* >'${server_log}' 2>&1 & echo \$! >'${SERVER_PIDFILE}'" || {
        log_message "ERROR: cannot start the in-container backend server"
        return 50
    }
    SERVER_PID="$(cat "${SERVER_PIDFILE}" 2>/dev/null || true)"
    return 0
}

# Waits until the in-container backend server has exited (it is not a child of
# this shell, so its status is derived from the process table plus the "SERVER"
# marker that run_sample verifies in the server log).
wait_for_server_exit() {
    local timeout_ticks=1500 tick
    for tick in $(seq 1 "${timeout_ticks}"); do
        container_pid_alive "${SERVER_PID}" || return 0
        sleep 0.02
    done
    log_message "ERROR: backend server did not exit in time"
    stop_server
    return 50
}

scenario_client_port() {
    local scenario="$1"
    if [[ "$(scenario_path "${scenario}")" == direct ]]; then
        if [[ "$(scenario_mode "${scenario}")" == latency ]]; then
            printf '%s\n' "${RINETD_LATENCY_BACKEND_PORT}"
        else
            printf '%s\n' "${RINETD_THROUGHPUT_BACKEND_PORT}"
        fi
    else
        if [[ "$(scenario_mode "${scenario}")" == latency ]]; then
            printf '%s\n' "${RINETD_LATENCY_LISTEN_PORT}"
        else
            printf '%s\n' "${RINETD_THROUGHPUT_LISTEN_PORT}"
        fi
    fi
}

run_sample() {
    local scenario="$1" label="$2"
    local directory="${RUNS_DIR}/${scenario}"
    local mode client_port server_log client_log client_json client_rc
    mkdir -p "${directory}"
    mode="$(scenario_mode "${scenario}")" || return 50
    client_port="$(scenario_client_port "${scenario}")" || return 50
    server_log="${directory}/server-${label}.log"
    client_log="${directory}/${label}.log"
    client_json="${directory}/${label}.json"

    if [[ "${mode}" == throughput ]]; then
        start_server "${server_log}" serve-sink "${RINETD_THROUGHPUT_BACKEND_PORT}" \
            "$(scenario_connections "${scenario}")" || return 50
    else
        start_server "${server_log}" serve-echo "${RINETD_LATENCY_BACKEND_PORT}" \
            "${RINETD_LATENCY_REQUEST_BYTES}" || return 50
    fi
    if ! wait_for_server "${server_log}"; then
        stop_server
        return 50
    fi

    client_rc=0
    if [[ "${mode}" == throughput ]]; then
        # The timing harness runs inside the private container at the shared work
        # directory, so the sample is a container-native child process.
        rinetd_container_exec_at "${PERF_WORK_DIR}" \
            python3 "${SCRIPT_DIR}/scripts/run_timed.py" \
            --json "${client_json}" \
            --log "${client_log}" \
            --timeout 300 \
            -- "${RINETD_BENCH_BIN}" client-throughput "${client_port}" \
            "$(scenario_payload "${scenario}")" "$(scenario_connections "${scenario}")" \
            || client_rc=$?
    else
        rinetd_container_exec_at "${PERF_WORK_DIR}" \
            python3 "${SCRIPT_DIR}/scripts/run_timed.py" \
            --json "${client_json}" \
            --log "${client_log}" \
            --timeout 300 \
            -- "${RINETD_BENCH_BIN}" client-latency "${client_port}" \
            "${RINETD_LATENCY_REQUEST_BYTES}" "${RINETD_LATENCY_ROUND_TRIPS}" "${RINETD_LATENCY_DISCARD}" \
            || client_rc=$?
    fi

    wait_for_server_exit || return 50
    SERVER_PID=""
    rm -f -- "${SERVER_PIDFILE}"
    SERVER_PIDFILE=""

    if (( client_rc != 0 )); then
        log_message "ERROR: scenario ${scenario} ${label} client failed with exit code ${client_rc}"
        [[ -f "${client_log}" ]] && tail -n 40 -- "${client_log}" | while IFS= read -r line; do log_message "  ${line}"; done
        return 50
    fi
    if ! grep -q '^SERVER ' "${server_log}" 2>/dev/null; then
        log_message "ERROR: scenario ${scenario} ${label} server did not report a SERVER line"
        tail -n 40 -- "${server_log}" | while IFS= read -r line; do log_message "  ${line}"; done
        return 50
    fi
    return 0
}

write_raw_output() {
    local scenario label directory value version_line
    version_line="$(rinetd_container_exec "${RINETD_BIN}" -v 2>&1 | head -n 1)"
    {
        printf '# rinetd loopback TCP benchmark raw output\n'
        printf '# generated: %s\n' "$(TZ=UTC-8 date '+%F %T')"
        printf '# reps: %s, warmup: %s\n' "${RINETD_REPS}" "${RINETD_WARMUP_REPS}"
        printf '# rinetd: %s\n' "${version_line}"
        for scenario in "${RINETD_SCENARIOS[@]}"; do
            directory="${RUNS_DIR}/${scenario}"
            for label in warmup1 $(for value in $(seq 1 "${RINETD_REPS}"); do printf 'rep%s ' "${value}"; done); do
                [[ -f "${directory}/server-${label}.log" ]] || continue
                printf '===== %s / %s (server) =====\n' "${scenario}" "${label}"
                cat -- "${directory}/server-${label}.log"
                [[ -f "${directory}/${label}.log" ]] || continue
                printf '===== %s / %s (client) =====\n' "${scenario}" "${label}"
                cat -- "${directory}/${label}.log"
            done
        done
    } > "${RESULTS_DIR}/raw-output.log"
}

verify_samples() {
    local scenario label directory value
    for scenario in "${RINETD_SCENARIOS[@]}"; do
        directory="${RUNS_DIR}/${scenario}"
        for value in $(seq 1 "${RINETD_WARMUP_REPS}"); do
            [[ -f "${directory}/warmup${value}.json" ]] || {
                log_message "ERROR: missing warmup sample ${scenario}/warmup${value}.json"
                return 50
            }
        done
        for value in $(seq 1 "${RINETD_REPS}"); do
            [[ -f "${directory}/rep${value}.json" ]] || {
                log_message "ERROR: missing measured sample ${scenario}/rep${value}.json"
                return 50
            }
            [[ -f "${directory}/server-rep${value}.log" ]] || {
                log_message "ERROR: missing server log ${scenario}/server-rep${value}.log"
                return 50
            }
        done
    done
    return 0
}

run_rinetd_benchmarks() {
    local scenario rep
    initialize_runtime || return $?

    check_rinetd_container || return $?

    load_ports || return 50
    if ! rinetd_container_exec test -x "${RINETD_BENCH_BIN}"; then
        log_message "ERROR: benchmark harness is unavailable: ${RINETD_BENCH_BIN}"
        return 50
    fi
    if [[ -f "${RINETD_PIDFILE:-}" ]] && ! container_pid_alive "$(cat "${RINETD_PIDFILE}" 2>/dev/null)"; then
        log_message "ERROR: rinetd is not running; the start stage must succeed first"
        return 50
    fi
    trap stop_server EXIT
    rm -rf -- "${RUNS_DIR}"
    mkdir -p "${RUNS_DIR}"

    for scenario in "${RINETD_SCENARIOS[@]}"; do
        log_message "scenario ${scenario}: warmup (${RINETD_WARMUP_REPS} run(s))"
        for rep in $(seq 1 "${RINETD_WARMUP_REPS}"); do
            run_sample "${scenario}" "warmup${rep}" || return 50
        done
        log_message "scenario ${scenario}: ${RINETD_REPS} measured repetition(s)"
        for rep in $(seq 1 "${RINETD_REPS}"); do
            run_sample "${scenario}" "rep${rep}" || return 50
        done
    done

    write_raw_output
    verify_samples || return 50

    log_message "aggregating ${RINETD_REPS} repetition(s) per scenario"
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        --runs "${RUNS_DIR}" \
        --output "${RESULTS_DIR}/benchmark_rinetd.json" \
        --reps "${RINETD_REPS}" \
        --warmup-reps "${RINETD_WARMUP_REPS}" || {
        log_message "ERROR: rinetd result parser failed; the measurement set is incomplete or invalid"
        return 50
    }
    log_message "rinetd benchmark results written to ${RESULTS_DIR}/benchmark_rinetd.json"
}
