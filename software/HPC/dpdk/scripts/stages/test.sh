#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_single_autotest() {
    local tag="$1"
    local cores="$2"
    local test_name="$3"
    local log_file="$4"
    local main_cpu="${cores%%,*}"
    local status=0
    main_cpu="${main_cpu%%-*}"
    log "running ${test_name} (tag=${tag}, cores=${cores}, main=${main_cpu})"
    set +e
    container_exec env -u DPDK_TEST -u DPDK_TEST_PARAMS -u DPDK_TEST_SKIP \
        "${DPDK_TEST_BIN}" \
        -l "${cores}" --main-lcore="${main_cpu}" \
        --no-pci --no-huge -m "${DPDK_MEM_MB}" --no-telemetry \
        --file-prefix="cpu-${PERF_RUN_ID}-${tag}" \
        -- "${test_name}" \
        2>&1 | tee "${log_file}"
    status="${PIPESTATUS[0]}"
    set -e
    if [[ "${status}" -ne 0 ]]; then
        log "ERROR: ${test_name} (${tag}) exited with status ${status}"
        return 50
    fi
    if grep -q 'Test Failed' "${log_file}" || ! grep -q 'Test OK' "${log_file}"; then
        log "ERROR: ${test_name} (${tag}) did not finish cleanly with Test OK"
        return 50
    fi
}

collect_container_env_logs() {
    local logs_dir="$1"
    container_exec uname -a > "${logs_dir}/uname.txt" 2>&1 || true
    container_exec lscpu > "${logs_dir}/lscpu.txt" 2>&1 || true
    container_exec lscpu -e=CPU,NODE,SOCKET,CORE,ONLINE > "${logs_dir}/cpu-topology.txt" 2>&1 || true
    container_exec numactl --hardware > "${logs_dir}/numa.txt" 2>&1 || true
    container_exec cat /proc/meminfo > "${logs_dir}/meminfo.txt" 2>&1 || true
    container_exec getconf PAGESIZE > "${logs_dir}/base-page-size.txt" 2>&1 || true
}

run_dpdk_benchmarks() {
    local logs_dir result_json bench_cpu bench_pair tsc_hz source_sha cache_line_size r
    initialize_runtime || return $?
    check_dpdk_container || return $?
    logs_dir="${RESULTS_DIR}/logs"
    result_json="${RESULTS_DIR}/benchmark_dpdk.json"
    [[ ! -e "${result_json}" ]] || {
        log "ERROR: refusing to overwrite existing benchmark result: ${result_json}"
        return 50
    }
    [[ -s "${DPDK_CPU_STATE_FILE}" && -s "${DPDK_TSC_STATE_FILE}" && -s "${DPDK_SHA_STATE_FILE}" && -s "${DPDK_CACHELINE_STATE_FILE}" ]] || {
        log 'ERROR: required build/start state files are missing'
        return 50
    }
    mkdir -p "${logs_dir}"
    collect_container_env_logs "${logs_dir}"

    bench_cpu="$(python3 -c 'import json, sys; print(json.load(open(sys.argv[1]))["bench_cpu"])' "${DPDK_CPU_STATE_FILE}")"
    bench_pair="$(python3 -c 'import json, sys; print(json.load(open(sys.argv[1]))["bench_pair"])' "${DPDK_CPU_STATE_FILE}")"
    tsc_hz="$(tr -d '\r\n' < "${DPDK_TSC_STATE_FILE}")"
    source_sha="$(tr -d '\r\n' < "${DPDK_SHA_STATE_FILE}")"
    cache_line_size="$(tr -d '\r\n' < "${DPDK_CACHELINE_STATE_FILE}")"

    # 1. Hash (1 core): 1 warmup + 3 formal runs
    run_single_autotest "hash-warmup" "${bench_cpu}" "hash_perf_autotest" "${logs_dir}/hash-warmup.log" || return $?
    for r in 1 2 3; do
        run_single_autotest "hash-run${r}" "${bench_cpu}" "hash_perf_autotest" "${logs_dir}/hash-run${r}.log" || return $?
    done

    # 2. Ring (2 distinct physical cores on NUMA 0): 1 warmup + 3 formal runs
    run_single_autotest "ring-warmup" "${bench_pair}" "ring_perf_autotest" "${logs_dir}/ring-warmup.log" || return $?
    for r in 1 2 3; do
        run_single_autotest "ring-run${r}" "${bench_pair}" "ring_perf_autotest" "${logs_dir}/ring-run${r}.log" || return $?
    done

    # 3. Memcpy (1 core): 1 formal run (built-in uncached warmup in upstream test_memcpy_perf.c)
    run_single_autotest "memcpy-1core" "${bench_cpu}" "memcpy_perf_autotest" "${logs_dir}/memcpy-1core.log" || return $?

    # 4. Mempool (1 core): 1 formal run
    run_single_autotest "mempool-1core" "${bench_cpu}" "mempool_perf_autotest_1core" "${logs_dir}/mempool-1core.log" || return $?

    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        --logs-dir "${logs_dir}" \
        --output "${result_json}" \
        --tsc-hz "${tsc_hz}" \
        --source-md5 "${DPDK_EXPECTED_MD5}" \
        --source-sha256 "${source_sha}" \
        --cache-line-size "${cache_line_size}" \
        --cpu-selection "${DPDK_CPU_STATE_FILE}" \
        --mem-mb "${DPDK_MEM_MB}" || return 50
    log 'normalized DPDK 26.11.0 CPU benchmark results successfully'
}
