#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_gcc_runtime() {
    local cleanup_failed=0 previous_aslr
    initialize_runtime || return $?
    if [[ -f "${ASLR_STATE_FILE}" ]]; then
        previous_aslr="$(<"${ASLR_STATE_FILE}")"
        if [[ ! "${previous_aslr}" =~ ^[0-9]+$ ]]; then
            log_message "ERROR: recorded ASLR setting is invalid: ${previous_aslr}"
            cleanup_failed=1
        elif [[ "${EUID}" -eq 0 ]]; then
            if ! printf '%s\n' "${previous_aslr}" > /proc/sys/kernel/randomize_va_space; then
                log_message "ERROR: failed to restore the ASLR setting"
                cleanup_failed=1
            fi
        elif ! printf '%s\n' "${previous_aslr}" | sudo -n tee /proc/sys/kernel/randomize_va_space >/dev/null; then
            log_message "ERROR: failed to restore the ASLR setting"
            cleanup_failed=1
        fi
    fi
    if grep -F " ${SPEC_MOUNT_DIR} " /proc/mounts >/dev/null 2>&1; then
        if [[ "${EUID}" -eq 0 ]]; then
            if ! umount "${SPEC_MOUNT_DIR}"; then
                log_message "ERROR: failed to unmount the SPEC CPU2017 ISO"
                cleanup_failed=1
            fi
        elif ! sudo -n umount "${SPEC_MOUNT_DIR}"; then
            log_message "ERROR: failed to unmount the SPEC CPU2017 ISO"
            cleanup_failed=1
        fi
    fi
    if [[ -e "${BENCHMARK_DATA_DIR}" || -L "${BENCHMARK_DATA_DIR}" ]]; then
        if [[ -L "${BENCHMARK_DATA_DIR}" || ! -d "${BENCHMARK_DATA_DIR}" ]] || \
            [[ "${BENCHMARK_DATA_DIR}" != "${GCC_BENCHMARK_DATA_ROOT%/}/gcc-${PERF_RUN_ID}" ]] || \
            [[ ! -f "${BENCHMARK_DATA_DIR}/.gcc-run-id" ]] || \
            [[ "$(<"${BENCHMARK_DATA_DIR}/.gcc-run-id")" != "${PERF_RUN_ID}" ]]; then
            log_message "ERROR: refusing to clean unverified GCC benchmark data directory: ${BENCHMARK_DATA_DIR}"
            cleanup_failed=1
        fi
        if [[ "${cleanup_failed}" -eq 0 ]] && ! rm -rf -- "${BENCHMARK_DATA_DIR}"; then
            log_message "ERROR: failed to clean GCC benchmark data directory: ${BENCHMARK_DATA_DIR}"
            cleanup_failed=1
        fi
    fi
    if [[ "${cleanup_failed}" -ne 0 ]]; then
        return 70
    fi
    log_message "cleaned the private SPEC CPU2017 installation and benchmark data"
}
