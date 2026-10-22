#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_mysql_benchmarks() {
    local scenario threads snapshot_bytes available_bytes
    local -a threads_for_scenario
    local raw_output="${RESULTS_DIR}/sysbench_raw.log"
    local runs_dir="${RESULTS_DIR}/sysbench-runs"

    initialize_runtime || return $?
    require_mysql_tools || return $?
    if ! MYSQL_PWD="${MYSQL_PASSWORD}" "${MYSQL_BIN}" \
        "-h${MYSQL_HOST}" "-P${MYSQL_PORT}" "-u${MYSQL_DB_USER}" -N -e 'SELECT 1' \
        >/dev/null 2>&1; then
        log_message "ERROR: MySQL is not reachable on ${MYSQL_HOST}:${MYSQL_PORT}"
        return 50
    fi
    if ! bash "${SCRIPT_DIR}/scripts/prepare_sysbench.sh" \
        "${PERF_WORK_DIR}/sysbench-tools" "${MYSQL_BASE_DIR}/bin/mysql_config"; then
        log_message "ERROR: failed to build pinned Sysbench client"
        return 50
    fi
    mkdir -p "${runs_dir}"
    : > "${raw_output}"

    MYSQL_PWD="${MYSQL_PASSWORD}" "${MYSQL_BIN}" \
        "-h${MYSQL_HOST}" "-P${MYSQL_PORT}" "-u${MYSQL_DB_USER}" \
        -e 'CREATE DATABASE IF NOT EXISTS sbtest' || return 50
    log_message 'preparing 64 Sysbench tables with 10,000,000 rows each (256 threads)'
    run_sysbench read_write 256 0 prepare || return 50

    if [[ -e "${MYSQL_SNAPSHOT_DIR}" ]]; then
        log_message "ERROR: data snapshot already exists: ${MYSQL_SNAPSHOT_DIR}"
        return 50
    fi
    shutdown_mysql_server || return 50
    snapshot_bytes="$(du -sb "${DATADIR}" | awk '{print $1}')"
    available_bytes="$(df -B1 --output=avail "${PERF_WORK_DIR}" | tail -n 1 | tr -d ' ')"
    if (( available_bytes < snapshot_bytes + 10737418240 )); then
        log_message "ERROR: insufficient disk space for the private MySQL data snapshot"
        return 50
    fi
    log_message "copying prepared data to ${MYSQL_SNAPSHOT_DIR}"
    cp -a --reflink=never "${DATADIR}" "${MYSQL_SNAPSHOT_DIR}" || return 50
    launch_mysql_server benchmark || return 50
    MYSQL_PWD="${MYSQL_PASSWORD}" "${MYSQL_BIN}" \
        "-h${MYSQL_HOST}" "-P${MYSQL_PORT}" "-u${MYSQL_DB_USER}" -N \
        -e 'SELECT @@innodb_flush_log_at_trx_commit, @@innodb_use_native_aio, @@log_bin, @@max_connections, @@max_prepared_stmt_count' \
        | { printf '# benchmark configuration: flush_at_commit native_aio log_bin max_connections max_prepared_stmt_count\n'; cat; } \
        | tee -a "${raw_output}" "${RESULTS_DIR}/mysql-benchmark-config.log" || return 50

    for scenario in read_only read_write write_only; do
        if [[ "${scenario}" == read_write ]]; then
            shutdown_mysql_server || return 50
            launch_mysql_server benchmark || return 50
        elif [[ "${scenario}" == write_only ]]; then
            shutdown_mysql_server || return 50
            rm -rf -- "${DATADIR}"
            cp -a --reflink=never "${MYSQL_SNAPSHOT_DIR}" "${DATADIR}" || return 50
            launch_mysql_server benchmark || return 50
        fi
        sleep 30
        log_message "warming up ${scenario}: 64 threads for 300 seconds"
        run_sysbench read_only 64 300 "warmup-${scenario}" || return 50
        threads_for_scenario=(256 128 32 1)
        for threads in "${threads_for_scenario[@]}"; do
            log_message "testing ${scenario}: ${threads} threads, 120 seconds"
            run_sysbench "${scenario}" "${threads}" 120 "run-${scenario}-threads${threads}" || return 50
        done
    done
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT
    python3 "${SCRIPT_DIR}/scripts/results/collect_sysbench.py" \
        "${runs_dir}" "${RESULTS_DIR}/results.json" || return 50
    log_message 'single-instance Sysbench suite completed'
}
