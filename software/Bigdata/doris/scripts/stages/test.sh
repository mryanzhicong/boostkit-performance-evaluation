#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

doris_client() {
    doris_exec python3 "${PERF_WORK_DIR}/tools/doris_client.py" "$@"
}

prepare_tpch_kit() {
    local zip="${DORIS_TPCH_OFFLINE_DIR}/tpch-kit-master.zip"
    local kit="${PERF_WORK_DIR}/tpch-kit"
    if [[ ! -d "${kit}/dbgen" ]]; then
        if [[ -s "${zip}" ]]; then
            cp -- "${zip}" "${PERF_WORK_DIR}/tpch-kit-master.zip" || return 30
        else
            with_network_proxy curl -fSL --retry 3 --connect-timeout 30 \
                -o "${PERF_WORK_DIR}/tpch-kit-master.zip" \
                "https://codeload.github.com/gregrahn/tpch-kit/zip/refs/heads/master" || return 30
        fi
        python3 -m zipfile -e "${PERF_WORK_DIR}/tpch-kit-master.zip" "${PERF_WORK_DIR}" || return 30
        [[ -d "${kit}/dbgen" ]] || { log_error 'tpch-kit archive has no dbgen'; return 30; }
    fi
    if ! doris_exec bash -c 'command -v gcc && command -v make' >/dev/null 2>&1; then
        doris_exec_root install -y gcc make || return 30
    fi
    if [[ ! -x "${kit}/dbgen/dbgen" ]]; then
        doris_exec bash -c "cd '${kit}/dbgen' && make -j\"\$(nproc)\"" >/dev/null || return 30
    fi
}

generate_tpch_data() {
    local data_dir="${PERF_WORK_DIR}/tpch-data/sf${DORIS_SF}"
    mkdir -p "${data_dir}"
    if [[ -s "${data_dir}/lineitem.tbl" ]]; then
        log_message "reusing generated TPC-H data: ${data_dir}"
        return 0
    fi
    doris_exec bash -c "cd '${PERF_WORK_DIR}/tpch-kit/dbgen' && ./dbgen -f -s '${DORIS_SF}' >/dev/null" || return 50
    local table
    for table in customer lineitem nation orders part partsupp region supplier; do
        mv "${PERF_WORK_DIR}/tpch-kit/dbgen/${table}.tbl" "${data_dir}/${table}.tbl" || return 50
        sed -i 's/|$//' "${data_dir}/${table}.tbl" || return 50
    done
}

create_schema() {
    local ddl="${PERF_WORK_DIR}/conf/doris-ddl.sql"
    mkdir -p "$(dirname "${ddl}")"
    cat > "${ddl}" <<EOF
DROP DATABASE IF EXISTS ${DORIS_DATABASE};
CREATE DATABASE ${DORIS_DATABASE};
USE ${DORIS_DATABASE};
CREATE TABLE region (
  r_regionkey INT, r_name VARCHAR(25), r_comment VARCHAR(152))
  DUPLICATE KEY(r_regionkey) DISTRIBUTED BY HASH(r_regionkey) BUCKETS 1
  PROPERTIES("replication_num"="1");
CREATE TABLE nation (
  n_nationkey INT, n_name VARCHAR(25), n_regionkey INT, n_comment VARCHAR(152))
  DUPLICATE KEY(n_nationkey) DISTRIBUTED BY HASH(n_nationkey) BUCKETS 1
  PROPERTIES("replication_num"="1");
CREATE TABLE supplier (
  s_suppkey INT, s_name VARCHAR(25), s_address VARCHAR(40), s_nationkey INT,
  s_phone VARCHAR(15), s_acctbal DECIMAL(15,2), s_comment VARCHAR(101))
  DUPLICATE KEY(s_suppkey) DISTRIBUTED BY HASH(s_suppkey) BUCKETS 4
  PROPERTIES("replication_num"="1");
CREATE TABLE customer (
  c_custkey INT, c_name VARCHAR(25), c_address VARCHAR(40), c_nationkey INT,
  c_phone VARCHAR(15), c_acctbal DECIMAL(15,2), c_mktsegment VARCHAR(10),
  c_comment VARCHAR(117))
  DUPLICATE KEY(c_custkey) DISTRIBUTED BY HASH(c_custkey) BUCKETS 8
  PROPERTIES("replication_num"="1");
CREATE TABLE part (
  p_partkey INT, p_name VARCHAR(55), p_mfgr VARCHAR(25), p_brand VARCHAR(10),
  p_type VARCHAR(25), p_size INT, p_container VARCHAR(10),
  p_retailprice DECIMAL(15,2), p_comment VARCHAR(23))
  DUPLICATE KEY(p_partkey) DISTRIBUTED BY HASH(p_partkey) BUCKETS 8
  PROPERTIES("replication_num"="1");
CREATE TABLE partsupp (
  ps_partkey INT, ps_suppkey INT, ps_availqty INT, ps_supplycost DECIMAL(15,2),
  ps_comment VARCHAR(199))
  DUPLICATE KEY(ps_partkey) DISTRIBUTED BY HASH(ps_partkey) BUCKETS 16
  PROPERTIES("replication_num"="1");
CREATE TABLE orders (
  o_orderkey BIGINT, o_custkey INT, o_orderstatus VARCHAR(1),
  o_totalprice DECIMAL(15,2), o_orderdate DATE, o_orderpriority VARCHAR(15),
  o_clerk VARCHAR(15), o_shippriority INT, o_comment VARCHAR(79))
  DUPLICATE KEY(o_orderkey) DISTRIBUTED BY HASH(o_orderkey) BUCKETS 16
  PROPERTIES("replication_num"="1");
CREATE TABLE lineitem (
  l_orderkey BIGINT, l_partkey INT, l_suppkey INT, l_linenumber INT,
  l_quantity DECIMAL(15,2), l_extendedprice DECIMAL(15,2), l_discount DECIMAL(15,2),
  l_tax DECIMAL(15,2), l_returnflag VARCHAR(1), l_linestatus VARCHAR(1),
  l_shipdate DATE, l_commitdate DATE, l_receiptdate DATE, l_shipinstruct VARCHAR(25),
  l_shipmode VARCHAR(10), l_comment VARCHAR(44))
  DUPLICATE KEY(l_orderkey) DISTRIBUTED BY HASH(l_orderkey) BUCKETS 32
  PROPERTIES("replication_num"="1");
CREATE VIEW revenue0 AS
SELECT l_suppkey AS supplier_no, sum(l_extendedprice * (1 - l_discount)) AS total_revenue
FROM lineitem
WHERE l_shipdate >= DATE '1996-01-01' AND l_shipdate < DATE '1996-04-01'
GROUP BY l_suppkey;
EOF
    doris_client exec --port "${DORIS_QUERY_PORT}" --file "${ddl}" || return 50
}

stream_load() {
    local table="$1" columns="$2" file="$3" response
    response="$(doris_exec curl -sS -L --location-trusted -u root: \
        -H 'format: csv' -H 'column_separator: |' -H "columns: ${columns}" \
        -T "${file}" \
        "http://127.0.0.1:${DORIS_HTTP_PORT}/api/${DORIS_DATABASE}/${table}/_stream_load")" || return 50
    python3 - "${table}" "${response}" <<'PY' || return 50
import json, sys
table, response = sys.argv[1], sys.argv[2]
try:
    payload = json.loads(response)
except ValueError:
    raise SystemExit(f"{table}: Stream Load returned non-JSON: {response[:300]}")
if payload.get("Status") != "Success":
    raise SystemExit(f"{table}: Stream Load failed: {response[:300]}")
print(f"{table}: {payload.get('NumberLoadedRows')} rows")
PY
}

load_tpch_data() {
    local data_dir="${PERF_WORK_DIR}/tpch-data/sf${DORIS_SF}"
    if ! doris_exec bash -c 'command -v curl' >/dev/null 2>&1; then
        doris_exec_root install -y curl || return 30
    fi
    stream_load region "r_regionkey,r_name,r_comment" "${data_dir}/region.tbl" || return 50
    stream_load nation "n_nationkey,n_name,n_regionkey,n_comment" "${data_dir}/nation.tbl" || return 50
    stream_load supplier "s_suppkey,s_name,s_address,s_nationkey,s_phone,s_acctbal,s_comment" "${data_dir}/supplier.tbl" || return 50
    stream_load customer "c_custkey,c_name,c_address,c_nationkey,c_phone,c_acctbal,c_mktsegment,c_comment" "${data_dir}/customer.tbl" || return 50
    stream_load part "p_partkey,p_name,p_mfgr,p_brand,p_type,p_size,p_container,p_retailprice,p_comment" "${data_dir}/part.tbl" || return 50
    stream_load partsupp "ps_partkey,ps_suppkey,ps_availqty,ps_supplycost,ps_comment" "${data_dir}/partsupp.tbl" || return 50
    stream_load orders "o_orderkey,o_custkey,o_orderstatus,o_totalprice,o_orderdate,o_orderpriority,o_clerk,o_shippriority,o_comment" "${data_dir}/orders.tbl" || return 50
    stream_load lineitem "l_orderkey,l_partkey,l_suppkey,l_linenumber,l_quantity,l_extendedprice,l_discount,l_tax,l_returnflag,l_linestatus,l_shipdate,l_commitdate,l_receiptdate,l_shipinstruct,l_shipmode,l_comment" "${data_dir}/lineitem.tbl" || return 50
}

verify_row_counts() {
    if [[ "${DORIS_SF}" != 1 ]]; then
        log_message "SF${DORIS_SF}: skipping the fixed SF1 row-count assertions"
        return 0
    fi
    local table expected actual
    declare -A expected_counts=(
        [region]=5 [nation]=25 [supplier]=10000 [customer]=150000
        [part]=200000 [partsupp]=800000 [orders]=1500000 [lineitem]=6001215
    )
    for table in "${!expected_counts[@]}"; do
        expected="${expected_counts[${table}]}"
        actual="$(doris_client query --port "${DORIS_QUERY_PORT}" --database "${DORIS_DATABASE}" \
            --sql "SELECT count(*) FROM ${table}" 2>/dev/null | tr -d '[:space:]')"
        [[ "${actual}" == "${expected}" ]] || {
            log_error "${table} has ${actual:-unknown} rows, expected ${expected}"; return 50;
        }
    done
}

run_doris_benchmark() {
    initialize_runtime || return $?
    check_container || return $?
    mkdir -p "${DORIS_RESULT_DIR}"
    prepare_tpch_kit || return $?
    generate_tpch_data || return $?
    create_schema || return $?
    load_tpch_data || return $?
    verify_row_counts || return $?

    cp -a "${CASE_DIR}/scripts/queries" "${PERF_WORK_DIR}/queries" || return 50
    log_message "running TPC-H 22 queries x ${DORIS_ROUNDS} rounds"
    doris_client run --port "${DORIS_QUERY_PORT}" --database "${DORIS_DATABASE}" \
        --queries "${PERF_WORK_DIR}/queries" --rounds "${DORIS_ROUNDS}" \
        --output "${DORIS_RESULT_DIR}/tpch_wall.csv" \
        --parallel-tasks "${DORIS_PARALLEL_PIPELINE_TASKS}" \
        --exec-mem-limit "${DORIS_EXEC_MEM_LIMIT}" \
        --timeout-seconds "${DORIS_QUERY_TIMEOUT}" || {
        log_error 'Doris TPC-H run failed'; return 50;
    }

    {
        printf '=== Doris frontends ===\n'
        cat "${DORIS_RESULT_DIR}/show_frontends.tsv" 2>/dev/null || true
        printf '\n=== Doris backends ===\n'
        cat "${DORIS_RESULT_DIR}/show_backends.tsv" 2>/dev/null || true
        printf '\n=== query wall times ===\n'
        cat "${DORIS_RESULT_DIR}/tpch_wall.csv"
    } > "${RESULTS_DIR}/benchmark_doris_raw.log"

    python3 "${CASE_DIR}/scripts/results/parse_benchmark.py" \
        --csv "${DORIS_RESULT_DIR}/tpch_wall.csv" \
        --output "${RESULTS_DIR}/benchmark_doris.json" \
        --rounds "${DORIS_ROUNDS}" \
        --sf "${DORIS_SF}" \
        --parallel-tasks "${DORIS_PARALLEL_PIPELINE_TASKS}" \
        --exec-mem-limit "${DORIS_EXEC_MEM_LIMIT}" || {
        log_error 'Doris metrics are missing or invalid'; return 50;
    }
}
