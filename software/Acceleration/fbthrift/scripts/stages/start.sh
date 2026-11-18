#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

select_fbthrift_port() {
    local digest
    digest="$(printf '%s' "${PERF_RUN_ID}" | cksum | awk '{print $1}')"
    printf '%s\n' "$(( 20000 + (digest % 2000) * 10 ))"
}

container_numa_nodes() {
    fbthrift_container_exec bash -c 'numactl --hardware 2>/dev/null | sed -nE "s/^available: ([0-9]+) nodes.*/\1/p"' 2>/dev/null \
        | tr -d '\r' | head -1
}

container_has_numactl() {
    fbthrift_container_exec bash -c 'command -v numactl >/dev/null 2>&1'
}

wait_fbthrift_server() {
    local port="$1" attempts=0 output
    while ((attempts < 90)); do
        if fbthrift_container_exec bash -c "exec 3<>/dev/tcp/127.0.0.1/${port}" 2>/dev/null; then
            return 0
        fi
        attempts=$((attempts + 1))
        sleep 2
    done
    output="$(fbthrift_container_exec cat "${SERVICE_DIR}/press_server.log" 2>/dev/null | tail -20 || true)"
    log_message "ERROR: press_server did not listen on port ${port}"
    printf '%s\n' "${output}"
    return 40
}

start_fbthrift_runtime() {
    initialize_runtime || return $?
    check_fbthrift_container || return $?
    local port nodes node numa_prefix=""
    port="${FBTHRIFT_PORT:-$(select_fbthrift_port)}"
    nodes="$(container_numa_nodes || true)"
    node="${FBTHRIFT_NUMA_NODE}"
    if ! [[ "${node}" =~ ^[0-9]+$ ]] || { [ -n "${nodes}" ] && [ "${node}" -ge "${nodes}" ]; }; then
        log_message "WARNING: NUMA node ${FBTHRIFT_NUMA_NODE} is unavailable (nodes=${nodes:-unknown}); using node 0"
        node=0
    fi
    if container_has_numactl && [ -n "${nodes}" ]; then
        numa_prefix="numactl -N ${node}"
    else
        node=0
    fi
    log_message "starting press_server on port ${port} (numa=${numa_prefix:-none}, cpu_threads=${FBTHRIFT_CPU_THREADS}, io_threads=${FBTHRIFT_IO_THREADS})"
    rm -f "${SERVICE_DIR}/press_server.log"
    fbthrift_container_exec bash -c "nohup ${numa_prefix} '${SERVER_BINARY}' --num_io_threads=${FBTHRIFT_IO_THREADS} --num_cpu_threads=${FBTHRIFT_CPU_THREADS} --port=${port} --use_io_uring=false > '${SERVICE_DIR}/press_server.log' 2>&1 < /dev/null &" || return 40
    wait_fbthrift_server "${port}" || return $?
    printf '%s\n' "${port}" > "${SERVICE_DIR}/port"
    printf '%s\n' "${node}" > "${SERVICE_DIR}/numa-node"
    printf '%s\n' "${nodes:-0}" > "${SERVICE_DIR}/numa-nodes"
    printf '{"port":%s,"numa_node":%s,"numa_nodes":%s,"cpu_threads":%s,"io_threads":%s,"io_uring":false}\n' \
        "${port}" "${node}" "${nodes:-0}" "${FBTHRIFT_CPU_THREADS}" "${FBTHRIFT_IO_THREADS}" \
        > "${RESULTS_DIR}/runtime.json"
    log_message "press_server is listening on ${port}"
}
