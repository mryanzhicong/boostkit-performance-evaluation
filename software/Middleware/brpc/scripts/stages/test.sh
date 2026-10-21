#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_brpc_rdma_performance() {
    local server_pid attachment_size repetition client_threads queue_depth max_inflight

    initialize_runtime || return $?
    [[ -x "${RDMA_CLIENT_BIN}" ]] || {
        log_message "ERROR: official performance client is unavailable: ${RDMA_CLIENT_BIN}"
        return 40
    }
    server_pid="$(read_pid_file "${SERVER_PID_FILE}")"
    process_is_alive "${server_pid}" || {
        log_message "ERROR: official performance server (pid ${server_pid:-unknown}) is not running"
        return 40
    }
    curl --noproxy '*' -fsS --max-time 2 -o /dev/null \
        "http://127.0.0.1:${RDMA_SERVER_PORT}/status" || {
        log_message "ERROR: official performance server is not responding"
        return 40
    }
    port_is_free "${RDMA_CLIENT_DUMMY_PORT}" || {
        log_message "ERROR: client dummy port ${RDMA_CLIENT_DUMMY_PORT} is already in use"
        return 20
    }
    : > "${CLIENT_LOG_FILE}"
    for attachment_size in "${BRPC_ATTACHMENT_SIZES[@]}"; do
        client_threads="${BRPC_MAX_CLIENT_THREADS}"
        queue_depth="${BRPC_MAX_QUEUE_DEPTH}"
        if ((attachment_size > 0)); then
            max_inflight=$((BRPC_MAX_INFLIGHT_ATTACHMENT_BYTES / attachment_size))
            if ((max_inflight < client_threads)); then
                client_threads="${max_inflight}"
            fi
            queue_depth=$((max_inflight / client_threads))
            if ((queue_depth > BRPC_MAX_QUEUE_DEPTH)); then
                queue_depth="${BRPC_MAX_QUEUE_DEPTH}"
            fi
        fi
        for ((repetition = 1; repetition <= BRPC_REPETITIONS; repetition += 1)); do
            log_message "running TCP baidu_std echo: ${attachment_size}B, ${client_threads} threads, depth ${queue_depth}, repetition ${repetition}/${BRPC_REPETITIONS} (20s)"
            if ! "${RDMA_CLIENT_BIN}" \
                --use_rdma=false \
                --protocol=baidu_std \
                --connection_type=single \
                --servers="127.0.0.1:${RDMA_SERVER_PORT}" \
                --thread_num="${client_threads}" \
                --queue_depth="${queue_depth}" \
                --bthread_concurrency=160 \
                --attachment_size="${attachment_size}" \
                --echo_attachment=true \
                --test_seconds=20 2>&1 | tee -a "${CLIENT_LOG_FILE}"; then
                log_message "ERROR: original performance client failed for ${attachment_size}B, repetition ${repetition}"
                return 50
            fi
        done
    done
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${CLIENT_LOG_FILE}" \
        "${RESULTS_DIR}/benchmark_brpc.json" || {
        log_message "ERROR: failed to normalize official client results"
        return 50
    }
    log_message "brpc benchmark results written to benchmark_client.log and benchmark_brpc.json"
}
