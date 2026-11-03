#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_daft_benchmarks() {
    local status=0
    initialize_runtime || return $?
    check_container || return $?
    python3 "${SCRIPT_DIR}/scripts/results/verify_data.py" \
        "${DAFT_PARQUET}" "${DAFT_MANIFEST}" || return 50
    [[ ! -e "${RESULTS_DIR}/timings.jsonl" ]] || {
        log 'ERROR: refusing to overwrite existing timings'; return 50;
    }
    log "running upstream TPC-H: SF${DAFT_SF}, 22 queries, ${DAFT_ROUNDS} rounds (first warmup)"
    docker exec -e "HOME=${PERF_WORK_DIR}" -e "TMPDIR=${TMPDIR}" \
        -e DAFT_RUNNER=native -e DAFT_PROGRESS_BAR=0 "${DAFT_CONTAINER_NAME}" \
        sh -c 'cd "$1" && exec "$2" "$3" --parquet "$4" --out "$5" --rounds "$6"' \
        sh "${DAFT_SOURCE}" "${DAFT_VENV}/bin/python" "${PERF_WORK_DIR}/tpch_driver.py" \
        "${DAFT_PARQUET}" "${RESULTS_DIR}" "${DAFT_ROUNDS}" 2>&1 \
        | tee "${RESULTS_DIR}/benchmark_daft_raw.log" || status="${PIPESTATUS[0]}"
    [[ "${status}" -eq 0 ]] || { log "ERROR: upstream TPC-H driver exited ${status}"; return 50; }
    log 'exporting all 22 query answers with the original driver for cross-architecture correctness checking'
    docker exec -e "HOME=${PERF_WORK_DIR}" -e "TMPDIR=${TMPDIR}" \
        -e DAFT_RUNNER=native -e DAFT_PROGRESS_BAR=0 "${DAFT_CONTAINER_NAME}" \
        sh -c 'cd "$1" && exec "$2" "$3" --mode answers --parquet "$4" --out "$5"' \
        sh "${DAFT_SOURCE}" "${DAFT_VENV}/bin/python" "${PERF_WORK_DIR}/tpch_driver.py" \
        "${DAFT_PARQUET}" "${RESULTS_DIR}" 2>&1 \
        | tee -a "${RESULTS_DIR}/benchmark_daft_raw.log" || status="${PIPESTATUS[0]}"
    [[ "${status}" -eq 0 ]] || { log "ERROR: TPC-H answer export exited ${status}"; return 50; }
    [[ "$(find "${RESULTS_DIR}/answers" -maxdepth 1 -type f -name 'q*.parquet' | wc -l)" == 22 ]] || {
        log 'ERROR: expected 22 query answer files'; return 50;
    }
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${RESULTS_DIR}/timings.jsonl" "${DAFT_MANIFEST}" \
        "${PERF_WORK_DIR}/daft-source-revision.txt" "${DAFT_SF}" "${DAFT_ROUNDS}" \
        "${RESULTS_DIR}/benchmark_daft.json" || return 50
}
