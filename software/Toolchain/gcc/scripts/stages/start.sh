#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_gcc_runtime() {
    initialize_runtime || return $?
    if [[ ! -x "${GCC_BIN}" || ! -x "${GXX_BIN}" || ! -x "${GFORTRAN_BIN}" ]]; then
        log_message "ERROR: private GCC C, C++, or Fortran compiler is missing"
        return 40
    fi
    if [[ ! -r "${SPEC_CPU2017_ISO}" ]]; then
        log_message "ERROR: SPEC CPU2017 ISO is missing or unreadable: ${SPEC_CPU2017_ISO}"
        return 40
    fi
    if [[ "${EUID}" -ne 0 ]] && ! sudo -n true >/dev/null 2>&1; then
        log_message "ERROR: passwordless sudo is required to mount the SPEC CPU2017 ISO"
        return 40
    fi
    if [[ ! "${SPEC_COPIES}" =~ ^[1-9][0-9]*$ ]]; then
        log_message "ERROR: SPEC_COPIES must be a positive integer: ${SPEC_COPIES}"
        return 40
    fi
    log_message "SPEC CPU2017 ISO is ready: ${SPEC_CPU2017_ISO}"
}
