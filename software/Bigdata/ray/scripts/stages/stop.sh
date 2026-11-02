#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_ray_runtime() {
    configure_runtime_paths || return $?
    if [[ -d "${PERF_WORK_DIR}/ray-temp/session_latest/logs" ]]; then
        mkdir -p "${RESULTS_DIR}/ray-logs"
        local log_file
        for log_file in raylet.out raylet.err gcs_server.out gcs_server.err; do
            if [[ -f "${PERF_WORK_DIR}/ray-temp/session_latest/logs/${log_file}" ]]; then
                cp -L -- "${PERF_WORK_DIR}/ray-temp/session_latest/logs/${log_file}" \
                    "${RESULTS_DIR}/ray-logs/${log_file}" || return 70
            fi
        done
    fi
    remove_ray_container || return $?
    log_message 'private Ray container stopped'
}
