#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_stream_runtime() {
    local threads
    initialize_runtime || return $?
    check_stream_vm || return $?
    vm_exec test -x "${GUEST_BINARY}" || {
        log 'ERROR: the compiled STREAM binary is missing inside the reference VM'
        return 40
    }
    threads="$(vm_exec nproc)"
    [[ "${threads}" == "${STREAM_VM_VCPUS}" ]] || {
        log "ERROR: reference VM reports ${threads} CPUs, expected ${STREAM_VM_VCPUS}"
        return 40
    }
    {
        printf '{"vm_name":"%s","vm_ip":"%s","vcpus":%s,"cores":%s,"threads_per_core":%s,"memory_mib":%s,"hugepages":%s,"numa_node":%s,"cpuset":"%s","accelerator":"%s","binary":"%s","status":"ready"}\n' \
            "${STREAM_VM_NAME}" "${STREAM_VM_IP}" "${STREAM_VM_VCPUS}" "${STREAM_VM_CORES_USED}" \
            "${STREAM_VM_THREADS_PER_CORE}" "${STREAM_VM_MEM_MIB}" "${STREAM_VM_HUGEPAGES_ENABLED}" \
            "${STREAM_VM_NUMA_NODE}" "${STREAM_VM_CPUSET}" "${STREAM_VM_ACCEL_USED}" "${GUEST_BINARY}" \
            > "${RESULTS_DIR}/service-state.json"
    }
    log "STREAM runtime is ready inside the reference VM (${STREAM_VM_CORES_USED}C/${STREAM_VM_VCPUS}T, ${STREAM_VM_MEM_MIB} MiB)"
}
