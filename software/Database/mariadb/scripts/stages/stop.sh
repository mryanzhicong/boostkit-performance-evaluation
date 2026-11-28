#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_mariadb_service() {
    local instance_id
    local stop_status=0

    configure_runtime_paths || return $?
    for ((instance_id = 1; instance_id <= MARIADB_INSTANCE_COUNT; instance_id++)); do
        configure_mariadb_instance "${instance_id}" || { stop_status=70; continue; }
        if [[ -n "${RESULTS_DIR:-}" && -d "${RESULTS_DIR}" && -f "${ERR_LOG}" ]]; then
            mkdir -p "${RESULTS_DIR}/service-logs"
            cp -- "${ERR_LOG}" "${RESULTS_DIR}/service-logs/mariadb-${instance_id}.err" 2>/dev/null || true
        fi
        if ! shutdown_mariadb_server; then
            stop_status=70
        fi
        if command -v docker >/dev/null 2>&1; then
            if ! remove_mariadb_container; then
                stop_status=70
            fi
        fi
    done
    if [[ -n "${MARIADB_INSTANCES_DIR:-}" && "${MARIADB_INSTANCES_DIR}" == "${PERF_WORK_DIR}/instances" && -d "${MARIADB_INSTANCES_DIR}" ]]; then
        rm -rf -- "${MARIADB_INSTANCES_DIR}" || stop_status=70
    fi
    return "${stop_status}"
}
