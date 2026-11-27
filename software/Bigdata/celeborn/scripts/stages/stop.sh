#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_celeborn_services() {
    local status=0
    if [[ -n "${CELEBORN_CONTAINER_NAME:-}" ]] && \
        [[ "$(docker inspect --format '{{.State.Running}}' "${CELEBORN_CONTAINER_NAME}" 2>/dev/null)" == true ]]; then
        log_message 'stopping the Celeborn master and worker'
        celeborn_container_exec "${CELEBORN_HOME}/sbin/stop-all.sh" >"${RESULTS_DIR}/celeborn-stop.log" 2>&1 || {
            log_message 'WARNING: sbin/stop-all.sh reported a failure; falling back to process cleanup'
            celeborn_container_exec_root bash -lc \
                "pkill -f 'org.apache.celeborn.service.deploy' || true" || true
        }
        local waited=0
        while (( waited < 60 )); do
            if ! celeborn_container_exec bash -lc "pgrep -f 'org.apache.celeborn.service.deploy' >/dev/null"; then
                log_message 'Celeborn processes stopped'
                break
            fi
            sleep 2
            waited=$((waited + 2))
        done
        if (( waited >= 60 )); then
            log_message 'WARNING: Celeborn processes are still visible after 60s of waiting'
        fi
    else
        log_message 'no running Celeborn container was found; nothing to stop'
    fi
    return "${status}"
}

stop_celeborn_runtime() {
    local status=0
    configure_runtime_paths || return $?
    celeborn_configure_container
    stop_celeborn_services || status=50
    python3 - "${RESULTS_DIR}/stop-report.json" "${status}" <<'PY'
import json
import sys

path, status = sys.argv[1], int(sys.argv[2])
with open(path, "w", encoding="utf-8") as handle:
    json.dump({"container_removed": False, "exit_status": status}, handle, indent=2, sort_keys=True)
    handle.write("\n")
PY
    if [[ "${CELEBORN_TEARDOWN:-0}" == 1 ]]; then
        remove_celeborn_container || status=60
    else
        log_message "keeping container ${CELEBORN_CONTAINER_NAME} (set CELEBORN_TEARDOWN=1 to remove it)"
    fi
    return "${status}"
}
