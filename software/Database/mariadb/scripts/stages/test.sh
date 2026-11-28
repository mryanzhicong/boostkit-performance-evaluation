#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

validate_prepared_sysbench_tables() {
    local table_count
    table_count="$(mariadb_client_exec "${MARIADB_PASSWORD}" "${MARIADB_BIN}" \
        "-h${MARIADB_HOST}" "-P${MARIADB_PORT}" "-u${MARIADB_DB_USER}" -N \
        -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='sbtest' AND table_name REGEXP '^sbtest([1-9]|1[0-6])$'")" || {
        log_message 'ERROR: failed to inspect prepared Sysbench tables'
        return 50
    }
    if [[ "${table_count}" != "${MARIADB_TABLES}" ]]; then
        log_message "ERROR: prepared Sysbench data has ${table_count} of ${MARIADB_TABLES} required tables; refusing to snapshot"
        return 50
    fi
    log_message "verified all ${MARIADB_TABLES} prepared Sysbench tables"
}

run_mariadb_benchmarks() {
    local scenario threads snapshot_bytes available_bytes
    local -a threads_for_scenario
    local raw_output="${RESULTS_DIR}/sysbench_raw.log"
    local runs_dir="${RESULTS_DIR}/sysbench-runs"

    initialize_runtime || return $?
    if (( MARIADB_INSTANCE_COUNT != 1 )); then
        log_message 'ERROR: multi-instance Sysbench testing is not enabled'
        return 50
    fi
    check_mariadb_container || return 50
    require_host_sysbench_tools || return $?
    if ! mariadb_client_exec "${MARIADB_PASSWORD}" "${MARIADB_BIN}" \
        "-h${MARIADB_HOST}" "-P${MARIADB_PORT}" "-u${MARIADB_DB_USER}" -N -e 'SELECT 1' \
        >/dev/null 2>&1; then
        log_message "ERROR: MariaDB is not reachable on ${MARIADB_HOST}:${MARIADB_PORT}"
        return 50
    fi
    if ! bash "${SCRIPT_DIR}/scripts/prepare_sysbench.sh" \
        "${PERF_WORK_DIR}/sysbench-tools" "${MARIADB_CONFIG_BIN}"; then
        log_message 'ERROR: failed to build pinned Sysbench client on host'
        return 50
    fi
    mkdir -p "${runs_dir}"
    : > "${raw_output}"

    mariadb_client_exec "${MARIADB_PASSWORD}" "${MARIADB_BIN}" \
        "-h${MARIADB_HOST}" "-P${MARIADB_PORT}" "-u${MARIADB_DB_USER}" \
        -e 'CREATE DATABASE IF NOT EXISTS sbtest' || return 50
    log_message "preparing ${MARIADB_TABLES} Sysbench tables with ${MARIADB_TABLE_SIZE} rows each (${MARIADB_PREPARE_THREADS} threads)"
    run_sysbench read_write "${MARIADB_PREPARE_THREADS}" 0 prepare || return 50
    validate_prepared_sysbench_tables || return 50

    if [[ -e "${MARIADB_SNAPSHOT_DIR}" ]]; then
        log_message "ERROR: data snapshot already exists: ${MARIADB_SNAPSHOT_DIR}"
        return 50
    fi
    shutdown_mariadb_server || return 50
    snapshot_bytes="$(du -sb "${DATADIR}" | awk '{print $1}')"
    available_bytes="$(df -B1 --output=avail "${PERF_WORK_DIR}" | tail -n 1 | tr -d ' ')"
    if (( available_bytes < snapshot_bytes + 5368709120 )); then
        log_message 'ERROR: insufficient disk space for the private MariaDB data snapshot'
        return 50
    fi
    log_message "copying prepared data to ${MARIADB_SNAPSHOT_DIR}"
    cp -a --reflink=never "${DATADIR}" "${MARIADB_SNAPSHOT_DIR}" || return 50
    launch_mariadb_server benchmark || return 50
    mariadb_client_exec "${MARIADB_PASSWORD}" "${MARIADB_BIN}" \
        "-h${MARIADB_HOST}" "-P${MARIADB_PORT}" "-u${MARIADB_DB_USER}" -N \
        -e 'SELECT @@innodb_flush_log_at_trx_commit, @@innodb_use_native_aio, @@log_bin, @@max_connections, @@max_prepared_stmt_count' \
        | { printf '# benchmark configuration: flush_at_commit native_aio log_bin max_connections max_prepared_stmt_count\n'; cat; } \
        | tee -a "${raw_output}" "${RESULTS_DIR}/mariadb-benchmark-config.log" || return 50

    for scenario in read_only read_write write_only; do
        if [[ "${scenario}" == read_write ]]; then
            shutdown_mariadb_server || return 50
            launch_mariadb_server benchmark || return 50
        elif [[ "${scenario}" == write_only ]]; then
            shutdown_mariadb_server || return 50
            rm -rf -- "${DATADIR}"
            cp -a --reflink=never "${MARIADB_SNAPSHOT_DIR}" "${DATADIR}" || return 50
            launch_mariadb_server benchmark || return 50
        fi
        sleep 10
        log_message "warming up ${scenario}: ${MARIADB_WARMUP_THREADS} threads for ${MARIADB_WARMUP_SECONDS} seconds"
        run_sysbench read_only "${MARIADB_WARMUP_THREADS}" "${MARIADB_WARMUP_SECONDS}" "warmup-${scenario}" || return 50
        threads_for_scenario=(256 128 32 1)
        for threads in "${threads_for_scenario[@]}"; do
            log_message "testing ${scenario}: ${threads} threads, ${MARIADB_MEASURE_SECONDS} seconds"
            run_sysbench "${scenario}" "${threads}" "${MARIADB_MEASURE_SECONDS}" "run-${scenario}-threads${threads}" || return 50
        done
    done
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT
    python3 "${SCRIPT_DIR}/scripts/results/collect_sysbench.py" \
        "${runs_dir}" "${RESULTS_DIR}/results.json" || return 50
    log_message 'single-instance MariaDB Sysbench suite completed'
}
