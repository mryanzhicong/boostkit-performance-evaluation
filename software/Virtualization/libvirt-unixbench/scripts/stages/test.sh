#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_vm_benchmark() {
    local index="$1" log_file="$2" ip
    local -a options=()
    # The reference procedure runs the complete official suite with one copy per
    # vCPU: ./Run -c 4 inside a 4 vCPU guest.  `timeout` has to wrap the ssh call
    # itself, because it cannot execute a shell function.
    ip="$(libvirt_guest_ip "${index}")" || return 40
    mapfile -t options < <(vm_ssh_opts)
    timeout "${LIBVIRT_REP_TIMEOUT}" ssh "${options[@]}" "root@${ip}" \
        "cd '${UNIXBENCH_GUEST_DIR}' && ./Run -c ${LIBVIRT_COPIES}" > "${log_file}" 2>&1 || {
        log "ERROR: ./Run -c ${LIBVIRT_COPIES} failed on VM ${index}; see ${log_file}"
        return 50
    }
    grep -q 'System Benchmarks Index Score' "${log_file}" || {
        log "ERROR: VM ${index} produced no complete UnixBench index; see ${log_file}"
        return 50
    }
    return 0
}

run_libvirt_unixbench_benchmarks() {
    local runs_root rep index pid failures total
    local -a pids=()
    initialize_runtime || return $?
    load_libvirt_vms || return $?
    check_libvirt_vms || return $?
    runs_root="${RESULTS_DIR}/runs"
    mkdir -p "${runs_root}" "${RESULTS_DIR}/unixbench-official"
    : > "${RESULTS_DIR}/benchmark_unixbench_raw.log"
    total="${LIBVIRT_REPS}"
    for ((rep = 1; rep <= total; rep++)); do
        local rep_dir="${runs_root}/rep${rep}"
        mkdir -p "${rep_dir}"
        if ((rep <= LIBVIRT_WARMUP_REPS)); then
            log "warm-up repetition ${rep}/${LIBVIRT_WARMUP_REPS} on ${LIBVIRT_VM_COUNT} VMs"
        else
            log "measured repetition $((rep - LIBVIRT_WARMUP_REPS))/$((total - LIBVIRT_WARMUP_REPS)) on ${LIBVIRT_VM_COUNT} VMs"
        fi
        pids=()
        failures=0
        for ((index = 0; index < LIBVIRT_VM_COUNT; index++)); do
            run_vm_benchmark "${index}" "${rep_dir}/vm${index}.log" &
            pids+=("$!")
        done
        for pid in "${pids[@]}"; do
            wait "${pid}" || failures=$((failures + 1))
        done
        ((failures == 0)) || {
            log "ERROR: ${failures} of ${LIBVIRT_VM_COUNT} VMs failed in repetition ${rep}"
            return 50
        }
        for ((index = 0; index < LIBVIRT_VM_COUNT; index++)); do
            printf '===== repetition %s / vm%s =====\n' "${rep}" "${index}" >> "${RESULTS_DIR}/benchmark_unixbench_raw.log"
            cat "${rep_dir}/vm${index}.log" >> "${RESULTS_DIR}/benchmark_unixbench_raw.log"
        done
        log "repetition ${rep}/${total} finished"
    done
    log 'collecting the official UnixBench report of every VM'
    for ((index = 0; index < LIBVIRT_VM_COUNT; index++)); do
        local target="${RESULTS_DIR}/unixbench-official/vm${index}"
        mkdir -p "${target}"
        vm_exec_shell "${index}" "cd '${UNIXBENCH_GUEST_DIR}' && tar -czf /tmp/unixbench-results.tgz results" || {
            log "ERROR: cannot archive the official UnixBench results of VM ${index}"; return 50
        }
        vm_copy_out "${index}" /tmp/unixbench-results.tgz "${target}/results.tgz" || {
            log "ERROR: cannot copy the official UnixBench results of VM ${index}"; return 50
        }
        tar -xzf "${target}/results.tgz" -C "${target}" || return 50
        rm -f "${target}/results.tgz"
    done
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${runs_root}" \
        "${RESULTS_DIR}/benchmark_unixbench.json" \
        "${RESULTS_DIR}/per-vm-scores.json" || return 50
}
