#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# ---------------------------------------------------------------------------
# 阶段 4：stop - 销毁集群并清理资源
# ---------------------------------------------------------------------------
stop_oceanbase_service() {
    initialize_runtime || return $?
    if [[ "${OB_DEPLOY_HOME}" != "${PERF_WORK_DIR}/ob" ||
          "${PERF_WORK_DIR}" == / || -z "${PERF_WORK_DIR}" ]]; then
        log_message "ERROR: refusing to clean unexpected OceanBase deployment path: ${OB_DEPLOY_HOME}"
        return 70
    fi
    collect_service_diagnostics || log_message 'WARN: could not save all observer/OBProxy service logs'
    if command -v obd >/dev/null 2>&1; then
        export OBD_HOME
        if ! obd cluster destroy demo -f --confirm; then
            log_message "WARN: obd cluster destroy reported an error; continuing with cleanup"
        fi
        if obd cluster list 2>/dev/null |
            grep -Eq '^\|[[:space:]]*demo[[:space:]]*\|.*\|[[:space:]]*configured[[:space:]]*\|'; then
            obd cluster prune-config demo --confirm ||
                log_message "WARN: failed to prune the configured-only demo record"
        fi
    else
        log_message "obd unavailable; skipping cluster teardown"
    fi
    rm -rf -- "${OB_DEPLOY_HOME}"
    log_message "OceanBase observer removed from ${OB_DEPLOY_HOME}"
}
