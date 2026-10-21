#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_sonic_go_runtime() {
    local runtime_dir="${PERF_WORK_DIR}/runtime"

    initialize_runtime || return $?
    if [[ ! -d "${runtime_dir}" ]]; then
        log_message "Sonic benchmark has no runtime directory to stop"
        return 0
    fi
    if [[ "${runtime_dir}" != "${PERF_WORK_DIR}/runtime" ]]; then
        log_message "ERROR: refusing to clean unexpected Sonic Go runtime directory: ${runtime_dir}"
        return 70
    fi
    if ! chmod -R u+w "${runtime_dir}" || ! rm -rf -- "${runtime_dir}"; then
        log_message "ERROR: failed to remove private Sonic Go runtime directory"
        return 70
    fi
    log_message "removed private Sonic Go runtime directory: ${runtime_dir}"
}
