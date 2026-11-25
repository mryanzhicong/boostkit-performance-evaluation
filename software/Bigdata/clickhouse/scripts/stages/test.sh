#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

ch_client() {
    ch_exec "${CH_BIN}" client --host 127.0.0.1 --port "${CH_TCP_PORT}" "$@"
}

prepare_tpch_kit() {
    local zip="${CH_TPCH_OFFLINE_DIR}/tpch-kit-master.zip"
    local kit="${PERF_WORK_DIR}/tpch-kit"
    if [[ ! -d "${kit}/dbgen" ]]; then
        if [[ -s "${zip}" ]]; then
            log_message "using local tpch-kit: ${zip}"
            cp -- "${zip}" "${PERF_WORK_DIR}/tpch-kit-master.zip" || return 30
        else
            log_message 'downloading tpch-kit'
            with_network_proxy curl -fSL --retry 3 --connect-timeout 30 \
                -o "${PERF_WORK_DIR}/tpch-kit-master.zip" \
                "https://codeload.github.com/gregrahn/tpch-kit/zip/refs/heads/master" || return 30
        fi
        rm -rf "${PERF_WORK_DIR}/tpch-kit-extract"
        mkdir -p "${PERF_WORK_DIR}/tpch-kit-extract"
        python3 -m zipfile -e "${PERF_WORK_DIR}/tpch-kit-master.zip" \
            "${PERF_WORK_DIR}/tpch-kit-extract" || return 30
        # The archive's top directory name changes between commits; locate dbgen
        # instead of assuming "tpch-kit-master".
        local dbgen_dir
        dbgen_dir="$(find "${PERF_WORK_DIR}/tpch-kit-extract" -maxdepth 3 -type d -name dbgen -print -quit)"
        [[ -n "${dbgen_dir}" ]] || {
            log_error 'tpch-kit archive has no dbgen directory'; return 30;
        }
        ln -sfn "$(dirname "${dbgen_dir}")" "${kit}"
    fi
    if ! ch_exec bash -c 'command -v gcc && command -v make' >/dev/null 2>&1; then
        log_message 'installing gcc and make inside the container'
        ch_exec_root install -y gcc make || return 30
    fi
    if [[ ! -x "${kit}/dbgen/dbgen" ]]; then
        log_message 'building TPC-H dbgen in the container'
        ch_exec bash -c "cd '${kit}/dbgen' && make -j\"\$(nproc)\"" >/dev/null || return 30
    fi
}

generate_tpch_data() {
    local data_dir="${PERF_WORK_DIR}/tpch-data/sf${CH_SF}"
    mkdir -p "${data_dir}"
    if [[ -s "${data_dir}/lineitem.tbl" ]]; then
        log_message "reusing generated TPC-H data: ${data_dir}"
        return 0
    fi
    log_message "generating TPC-H data at SF${CH_SF} in the container"
    ch_exec bash -c "cd '${PERF_WORK_DIR}/tpch-kit/dbgen' && ./dbgen -f -s '${CH_SF}' >/dev/null" || return 50
    mkdir -p "${data_dir}"
    local table
    for table in customer lineitem nation orders part partsupp region supplier; do
        mv "${PERF_WORK_DIR}/tpch-kit/dbgen/${table}.tbl" "${data_dir}/${table}.tbl" || return 50
        sed -i 's/|$//' "${data_dir}/${table}.tbl" || return 50
    done
}

create_schema() {
    local ddl="${PERF_WORK_DIR}/conf/tpch-ddl.sql"
    mkdir -p "$(dirname "${ddl}")"
    cat > "${ddl}" <<EOF
CREATE DATABASE IF NOT EXISTS ${CH_DATABASE};
DROP TABLE IF EXISTS ${CH_DATABASE}.lineitem;
CREATE TABLE ${CH_DATABASE}.lineitem (
  l_orderkey Int64, l_partkey Int32, l_suppkey Int32, l_linenumber Int32,
  l_quantity Decimal(15,2), l_extendedprice Decimal(15,2), l_discount Decimal(15,2),
  l_tax Decimal(15,2), l_returnflag String, l_linestatus String, l_shipdate Date,
  l_commitdate Date, l_receiptdate Date, l_shipinstruct String, l_shipmode String,
  l_comment String) ENGINE = MergeTree ORDER BY l_orderkey;
DROP TABLE IF EXISTS ${CH_DATABASE}.orders;
CREATE TABLE ${CH_DATABASE}.orders (
  o_orderkey Int64, o_custkey Int32, o_orderstatus String, o_totalprice Decimal(15,2),
  o_orderdate Date, o_orderpriority String, o_clerk String, o_shippriority Int32,
  o_comment String) ENGINE = MergeTree ORDER BY o_orderkey;
DROP TABLE IF EXISTS ${CH_DATABASE}.part;
CREATE TABLE ${CH_DATABASE}.part (
  p_partkey Int32, p_name String, p_mfgr String, p_brand String, p_type String,
  p_size Int32, p_container String, p_retailprice Decimal(15,2), p_comment String)
  ENGINE = MergeTree ORDER BY p_partkey;
DROP TABLE IF EXISTS ${CH_DATABASE}.partsupp;
CREATE TABLE ${CH_DATABASE}.partsupp (
  ps_partkey Int32, ps_suppkey Int32, ps_availqty Int32, ps_supplycost Decimal(15,2),
  ps_comment String) ENGINE = MergeTree ORDER BY (ps_partkey, ps_suppkey);
DROP TABLE IF EXISTS ${CH_DATABASE}.customer;
CREATE TABLE ${CH_DATABASE}.customer (
  c_custkey Int32, c_name String, c_address String, c_nationkey Int32, c_phone String,
  c_acctbal Decimal(15,2), c_mktsegment String, c_comment String)
  ENGINE = MergeTree ORDER BY c_custkey;
DROP TABLE IF EXISTS ${CH_DATABASE}.supplier;
CREATE TABLE ${CH_DATABASE}.supplier (
  s_suppkey Int32, s_name String, s_address String, s_nationkey Int32, s_phone String,
  s_acctbal Decimal(15,2), s_comment String) ENGINE = MergeTree ORDER BY s_suppkey;
DROP TABLE IF EXISTS ${CH_DATABASE}.nation;
CREATE TABLE ${CH_DATABASE}.nation (
  n_nationkey Int32, n_name String, n_regionkey Int32, n_comment String)
  ENGINE = MergeTree ORDER BY n_nationkey;
DROP TABLE IF EXISTS ${CH_DATABASE}.region;
CREATE TABLE ${CH_DATABASE}.region (
  r_regionkey Int32, r_name String, r_comment String) ENGINE = MergeTree ORDER BY r_regionkey;
DROP VIEW IF EXISTS ${CH_DATABASE}.revenue0;
CREATE VIEW ${CH_DATABASE}.revenue0 AS
SELECT l_suppkey AS supplier_no,
       sum(l_extendedprice * (1 - l_discount)) AS total_revenue
FROM ${CH_DATABASE}.lineitem
WHERE l_shipdate >= toDate('1996-01-01') AND l_shipdate < toDate('1996-04-01')
GROUP BY l_suppkey;
EOF
    ch_exec bash -c "'${CH_BIN}' client --host 127.0.0.1 --port '${CH_TCP_PORT}' --multiquery < '${ddl}'" || return 50
}

load_tpch_data() {
    local data_dir="${PERF_WORK_DIR}/tpch-data/sf${CH_SF}" table
    for table in region nation supplier customer part partsupp orders lineitem; do
        log_message "loading ${table}"
        ch_exec bash -c "'${CH_BIN}' client --host 127.0.0.1 --port '${CH_TCP_PORT}' \
            --format_csv_delimiter='|' \
            --query 'INSERT INTO ${CH_DATABASE}.${table} FORMAT CSV' < '${data_dir}/${table}.tbl'" || return 50
    done
}

verify_row_counts() {
    local expected table actual
    declare -A expected_counts=(
        [region]=5 [nation]=25 [supplier]=10000 [customer]=150000
        [part]=200000 [partsupp]=800000 [orders]=1500000 [lineitem]=6001215
    )
    if [[ "${CH_SF}" != 1 ]]; then
        log_message "SF${CH_SF}: skipping the fixed SF1 row-count assertions"
        return 0
    fi
    for table in "${!expected_counts[@]}"; do
        expected="${expected_counts[${table}]}"
        actual="$(ch_client --query "SELECT count() FROM ${CH_DATABASE}.${table}" 2>/dev/null | tr -d '[:space:]')"
        [[ "${actual}" == "${expected}" ]] || {
            log_error "${table} has ${actual:-unknown} rows, expected ${expected}"; return 50;
        }
    done
}

run_tpch_queries() {
    local round query_number qfile qid output
    local query_log="${CH_RESULT_DIR}/query_log.tsv"
    : > "${query_log}"
    for round in $(seq 1 "${CH_ROUNDS}"); do
        log_message "TPC-H round ${round}/${CH_ROUNDS}"
        for query_number in $(seq 1 22); do
            printf -v qid 'ck-%s-r%s-q%02d' "${PERF_RUN_ID}" "${round}" "${query_number}"
            printf -v qfile '%s/scripts/queries/q%d.sql' "${CASE_DIR}" "${query_number}"
            if ! ch_exec bash -c "'${CH_BIN}' client --host 127.0.0.1 --port '${CH_TCP_PORT}' \
                    --database '${CH_DATABASE}' --query_id '${qid}' --multiquery < '${qfile}'" \
                    > "${CH_RESULT_DIR}/q${query_number}_r${round}.out" 2>&1; then
                log_error "TPC-H q${query_number} failed in round ${round}"
                return 50
            fi
        done
        ch_client --query 'SYSTEM FLUSH LOGS' >/dev/null || return 50
        # query_log is written asynchronously: poll briefly until all 22
        # QueryFinish rows of this round are visible.
        local attempt rows=0
        for attempt in {1..15}; do
            output="$(ch_client --query "SELECT query_id, query_duration_ms, read_rows, memory_usage FROM system.query_log WHERE type = 'QueryFinish' AND query_id LIKE 'ck-${PERF_RUN_ID}-r${round}-%' FORMAT TSV" 2>/dev/null)" || return 50
            rows="$(printf '%s\n' "${output}" | grep -c "ck-${PERF_RUN_ID}-r${round}-q" || true)"
            (( rows >= 22 )) && break
            sleep 1
        done
        (( rows >= 22 )) || {
            log_error "round ${round}: only ${rows} of 22 queries reached system.query_log"
            return 50
        }
        printf '%s\n' "${output}" >> "${query_log}"
    done
}

run_clickhouse_benchmark() {
    initialize_runtime || return $?
    check_container || return $?
    mkdir -p "${CH_RESULT_DIR}"
    prepare_tpch_kit || return $?
    generate_tpch_data || return $?
    create_schema || return $?
    load_tpch_data || return $?
    verify_row_counts || return $?
    run_tpch_queries || return $?

    {
        printf '=== ClickHouse server settings ===\n'
        cat "${CH_RESULT_DIR}/server_settings.txt" 2>/dev/null || true
        printf '\n=== query log ===\n'
        cat "${CH_RESULT_DIR}/query_log.tsv"
        printf '\n=== query stderr (non-empty) ===\n'
        local file
        for file in "${CH_RESULT_DIR}"/*.out; do
            [[ -s "${file}" ]] || continue
            printf -- '--- %s ---\n' "$(basename "${file}")"
            cat "${file}"
        done
    } > "${RESULTS_DIR}/benchmark_clickhouse_raw.log"

    python3 "${CASE_DIR}/scripts/results/parse_benchmark.py" \
        --query-log "${CH_RESULT_DIR}/query_log.tsv" \
        --output "${RESULTS_DIR}/benchmark_clickhouse.json" \
        --rounds "${CH_ROUNDS}" \
        --sf "${CH_SF}" \
        --max-threads "${CH_MAX_THREADS}" \
        --max-memory-usage "${CH_MAX_MEMORY_USAGE}" \
        --max-server-memory-usage "${CH_MAX_SERVER_MEMORY_USAGE}" || {
        log_error 'ClickHouse metrics are missing or invalid'
        return 50
    }
}
