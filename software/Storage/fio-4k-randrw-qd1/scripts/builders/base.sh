#!/usr/bin/env bash
# Base build for the fio 4k random read/write cases.
set -o pipefail

build_fio_optimized() {
    log 'ERROR: the optimized fio build is not implemented'
    return 40
}

write_fio_build_variant() {
    local target="${RESULTS_DIR}/build_variant.json"
    cat > "${target}" <<JSON
{
  "variant": "${PERF_VARIANT}",
  "parameters": {
    "numjobs": ${FIO_NUMJOBS},
    "iodepth": ${FIO_IODEPTH},
    "block_size": "${FIO_BLOCK_SIZE}",
    "rw": "${FIO_RW}",
    "rwmixwrite": ${FIO_RWMIXWRITE},
    "rwmixread": ${FIO_RWMIXREAD},
    "ramp_time_seconds": ${FIO_RAMP_TIME},
    "runtime_seconds": ${FIO_RUNTIME},
    "logical_volumes": ${FIO_LV_COUNT},
    "logical_volume_size_gib": ${FIO_LV_SIZE_GIB},
    "vm_vcpus": ${FIO_VM_VCPUS},
    "vm_memory_mib": ${FIO_VM_MEM_MIB}
  }
}
JSON
}

build_fio_base() {
    local job_file gcc_version placeholders
    resolve_accel || return $?
    require_fio_vm_host || return $?
    ensure_fio_storage || return $?
    start_fio_vm || return $?
    install_fio_guest_packages || return $?
    verify_fio_version || return $?
    verify_guest_block_devices || return $?

    render_fio_job_file >/dev/null || {
        log 'ERROR: failed to render the fio job file'
        return 40
    }
    job_file="${RESULTS_DIR}/${FIO_GUEST_JOB}"
    push_fio_job_to_guest || return $?
    capture_fio_format_info || return $?
    record_fio_vm_environment || return $?
    write_fio_build_variant || return $?

    placeholders="$(vm_exec_shell "nproc" 2>/dev/null | tr -d '\r')"
    {
        printf '# collected_at: %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
        printf '# fio_version: %s\n' "${FIO_ACTUAL_VERSION:-unknown}"
        printf '# fio_package: fio-%s-%s\n' "${SOFTWARE_VERSION}" "${FIO_TOOLCHAIN_SOURCE:-dnf}"
        printf '# toolchain_source: %s\n' "${FIO_TOOLCHAIN_SOURCE:-dnf}"
        printf '# toolchain_install_attempt: %s\n' "${FIO_TOOLCHAIN_ATTEMPT:-1}"
        printf '# job_file: %s\n' "${FIO_GUEST_DIR}/${FIO_GUEST_JOB}"
        printf '# workload: %s bs=%s numjobs=%s iodepth=%s rwmixwrite=%s\n' \
            "${FIO_RW}" "${FIO_BLOCK_SIZE}" "${FIO_NUMJOBS}" "${FIO_IODEPTH}" "${FIO_RWMIXWRITE}"
        printf '# ramp_time_seconds: %s\n# runtime_seconds: %s\n' "${FIO_RAMP_TIME}" "${FIO_RUNTIME}"
        printf '# storage_volume_group: %s\n' "${FIO_VG_NAME}"
        printf '# storage_logical_volumes: %s\n' "${FIO_LV_COUNT}"
        printf '# storage_logical_volume_size_gib: %s\n' "${FIO_LV_SIZE_GIB}"
        printf '# guest_devices: %s\n' "$(fio_block_devices | tr '\n' ' ')"
        printf '# guest_vcpus: %s\n' "${placeholders:-unknown}"
        printf '# accelerator: %s\n' "${FIO_VM_ACCEL_USED}"
        printf '# job_file_sha256: %s\n' "$(sha256sum "${job_file}" | awk '{print $1}')"
    } > "${RESULTS_DIR}/build-info.txt"
    printf '%s\n' "${FIO_ACTUAL_VERSION}" > "${PERF_ACTUAL_VERSION_FILE}"
    gcc_version="$(vm_exec_shell 'command -v taskset >/dev/null && echo util-linux-ok' 2>/dev/null | tr -d '\r')"
    log "fio ${FIO_ACTUAL_VERSION} ready inside the reference VM (${FIO_LV_COUNT} LUN(s), ${gcc_version:-taskset unavailable})"
}
