#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

zkbench_java() {
    zk_exec "${ZK_JDK_HOME}/bin/java" -Dfile.encoding=UTF-8 \
        -cp "${ZK_BENCH_DIR}:${ZK_HOME}/lib/*" ZkBench "$@"
}

preload_keyspace() {
    local output count
    output="$(zk_mntr)" || { log_error 'cannot read mntr before preload'; return 40; }
    count="$(printf '%s\n' "${output}" | awk -F'\t' '$1 == "zk_znode_count" {print $2}')"
    if [[ -n "${count}" ]] && (( count >= ZK_KEYSPACE )); then
        log_message "keyspace already preloaded: zk_znode_count=${count} >= ${ZK_KEYSPACE}"
        return 0
    fi
    log_message "preloading ${ZK_KEYSPACE} znodes (value_size=${ZK_VALUE_SIZE})"
    zkbench_java --connect="127.0.0.1:${ZK_CLIENT_PORT}" --root=/zkbench \
        --mode=preload --keyspace="${ZK_KEYSPACE}" --value-size="${ZK_VALUE_SIZE}" \
        2>&1 | tee "${ZK_RESULT_DIR}/preload.log" >/dev/null || return 50
    output="$(zk_mntr)" || return 50
    count="$(printf '%s\n' "${output}" | awk -F'\t' '$1 == "zk_znode_count" {print $2}')"
    (( count >= ZK_KEYSPACE )) || {
        log_error "preload incomplete: zk_znode_count=${count:-unknown}"; return 50;
    }
    printf '%s\n' "${output}" > "${ZK_RESULT_DIR}/mntr_preload.txt"
}

append_mntr_summary() {
    local file="$1" tag="$2"
    {
        printf '=== mntr %s ===\n' "${tag}"
        grep -E '^(zk_avg_latency|zk_max_latency|zk_znode_count|zk_packets_received|zk_packets_sent|zk_server_state)' \
            "${file}" 2>/dev/null || true
    } >> "${ZK_RESULT_DIR}/benchmark_zookeeper_raw.log"
}

clean_created_znodes() {
    if [[ "${KEEP_CREATED:-0}" == 1 ]]; then
        log_message 'KEEP_CREATED=1: keeping /zkbench/c for inspection'
        return 0
    fi
    log_message 'cleaning znodes created by the create benchmark'
    zkbench_java --connect="127.0.0.1:${ZK_CLIENT_PORT}" --root=/zkbench --mode=clean \
        2>&1 | tee "${ZK_RESULT_DIR}/clean.log" >/dev/null || return 50
}

run_zookeeper_benchmark() {
    initialize_runtime || return $?
    check_container || return $?
    mkdir -p "${ZK_RESULT_DIR}/rounds"
    local csv="${ZK_RESULT_DIR}/zk_${PERF_RUN_ID}_${EXPECTED_ARCH}.csv"
    local raw="${RESULTS_DIR}/benchmark_zookeeper_raw.log"
    local err_file tag mode thread round total per_thread run_seq line
    printf 'label,arch,threads,mode,value_size,keyspace,ops_ok,ops_err,elapsed_s,throughput_ops,avg_us,p50_us,p95_us,p99_us,max_us\n' > "${csv}"
    : > "${raw}"

    preload_keyspace || return $?

    run_seq="${ZK_RUN_SEQ_START:-0}"
    for mode in ${ZK_MODES}; do
        for thread in ${ZK_THREADS}; do
            total="$(zk_total_ops "${thread}")"
            per_thread="$(( total / thread ))"
            for round in $(seq 1 "${ZK_ROUNDS}"); do
                tag="${mode}_t${thread}_r${round}"
                err_file="${ZK_RESULT_DIR}/rounds/${tag}.err"
                run_seq="$(( run_seq + 1 ))"
                if zk_mntr > "${ZK_RESULT_DIR}/rounds/${tag}_before.txt" 2>/dev/null; then :; fi
                log_message "running ${tag} (ops/thread=${per_thread}, run_seq=${run_seq})"
                if ! line="$(zkbench_java \
                        --connect="127.0.0.1:${ZK_CLIENT_PORT}" --root=/zkbench \
                        --mode="${mode}" --threads="${thread}" --ops="${per_thread}" \
                        --keyspace="${ZK_KEYSPACE}" --value-size="${ZK_VALUE_SIZE}" \
                        --warmup="${ZK_WARMUP_OPS}" --label="${PERF_RUN_ID}" \
                        --run-seq="${run_seq}" 2>"${err_file}" | tail -n 1)"; then
                    log_error "ZkBench failed: ${tag} (see ${err_file})"
                    return 50
                fi
                [[ -n "${line}" ]] || { log_error "empty ZkBench output: ${tag}"; return 50; }
                printf '%s\n' "${line}" >> "${csv}"
                printf '%s\n' "${line}" > "${ZK_RESULT_DIR}/rounds/${tag}.log"
                if [[ "$(awk -F, '{print $8}' <<< "${line}")" != "0" ]]; then
                    log_error "operations failed in ${tag}: ${line}"
                    return 50
                fi
                if zk_mntr > "${ZK_RESULT_DIR}/rounds/${tag}_after.txt" 2>/dev/null; then
                    append_mntr_summary "${ZK_RESULT_DIR}/rounds/${tag}_after.txt" "${tag}"
                fi
                sleep 5
            done
        done
    done

    clean_created_znodes || return $?
    # Keep the complete per-round evidence in one raw log.
    {
        printf '===== raw CSV =====\n'
        cat "${csv}"
        printf '\n===== per-round stderr =====\n'
        for err_file in "${ZK_RESULT_DIR}"/rounds/*.err; do
            [[ -s "${err_file}" ]] || continue
            printf '--- %s ---\n' "$(basename "${err_file}")"
            cat "${err_file}"
        done
    } >> "${raw}"

    python3 "${CASE_DIR}/scripts/results/parse_benchmark.py" \
        --csv "${csv}" \
        --output "${RESULTS_DIR}/benchmark_zookeeper.json" \
        --modes "${ZK_MODES}" \
        --threads "${ZK_THREADS}" \
        --rounds "${ZK_ROUNDS}" \
        --keyspace "${ZK_KEYSPACE}" \
        --value-size "${ZK_VALUE_SIZE}" \
        --warmup-ops "${ZK_WARMUP_OPS}" \
        --jvm-flags "${ZK_JVM_FLAGS}" || {
        log_error 'ZooKeeper metrics are missing or invalid'
        return 50
    }
}
