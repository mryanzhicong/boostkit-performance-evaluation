#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_pe_write() {
    local log="$1"
    log_message "PerformanceEvaluation randomWrite ${HBASE_DATA_SIZE_GB}GB, ${HBASE_PRESPLIT} regions, ${HBASE_WRITE_MAPS} maps"
    hbase_exec "${HBASE_HOME}/bin/hbase" org.apache.hadoop.hbase.PerformanceEvaluation \
        --size="${HBASE_DATA_SIZE_GB}" \
        --table="Test_${HBASE_DATA_SIZE_GB}GB" \
        --presplit="${HBASE_PRESPLIT}" \
        randomWrite "${HBASE_WRITE_MAPS}" > "${log}" 2>&1 || return 50
    grep -q 'Row count=' "${log}" || { log_error 'randomWrite produced no Row count'; return 50; }
}

flush_and_compact() {
    hbase_exec bash -c "echo \"flush 'Test_${HBASE_DATA_SIZE_GB}GB'\" | ${HBASE_HOME}/bin/hbase shell -n" \
        > "${HBASE_RESULT_DIR}/flush.log" 2>&1 || true
    hbase_exec bash -c "echo \"major_compact 'Test_${HBASE_DATA_SIZE_GB}GB'\" | ${HBASE_HOME}/bin/hbase shell -n" \
        > "${HBASE_RESULT_DIR}/major_compact.log" 2>&1 || true
}

run_pe_read() {
    local log="$1"
    hbase_exec "${HBASE_HOME}/bin/hbase" org.apache.hadoop.hbase.PerformanceEvaluation \
        --nomapred --rows="${HBASE_READ_ROWS}" \
        --table="Test_${HBASE_DATA_SIZE_GB}GB" \
        randomRead "${HBASE_READ_THREADS}" > "${log}" 2>&1 || return 50
    grep -q 'Avg TPS/QPS' "${log}" || { log_error 'randomRead produced no Avg TPS/QPS'; return 50; }
}

run_hbase_benchmark() {
    initialize_runtime || return $?
    check_container || return $?
    mkdir -p "${HBASE_RESULT_DIR}"
    local raw="${RESULTS_DIR}/benchmark_hbase_raw.log"
    : > "${raw}"

    local write_log="${HBASE_RESULT_DIR}/pe_randomWrite.log"
    run_pe_write "${write_log}" || return $?
    {
        printf '===== randomWrite =====\n'
        cat "${write_log}"
    } >> "${raw}"

    flush_and_compact || return $?

    local round read_log
    for round in $(seq 1 "${HBASE_ROUNDS}"); do
        read_log="${HBASE_RESULT_DIR}/pe_randomRead_round${round}.log"
        log_message "randomRead round ${round}/${HBASE_ROUNDS}"
        run_pe_read "${read_log}" || return $?
        {
            printf '\n===== randomRead round %s =====\n' "${round}"
            cat "${read_log}"
        } >> "${raw}"
    done

    python3 "${CASE_DIR}/scripts/results/parse_benchmark.py" \
        --raw "${raw}" \
        --output "${RESULTS_DIR}/benchmark_hbase.json" \
        --rounds "${HBASE_ROUNDS}" \
        --size-gb "${HBASE_DATA_SIZE_GB}" \
        --presplit "${HBASE_PRESPLIT}" \
        --read-threads "${HBASE_READ_THREADS}" \
        --read-rows "${HBASE_READ_ROWS}" || {
        log_error 'HBase metrics are missing or invalid'; return 50;
    }
}
