#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# ---------------------------------------------------------------------------
# 阶段 2：start - 确认服务可用
# ---------------------------------------------------------------------------
start_oceanbase_service() {
    initialize_runtime || return $?
    if ! check_observer_ready; then
        log_message "ERROR: OceanBase observer is not reachable on ${OB_HOST}:${OB_PORT}"
        return 40
    fi
    if ! check_proxy_ready; then
        log_message "ERROR: OBProxy test tenant is not reachable on ${OB_HOST}:${OB_PROXY_PORT}"
        return 40
    fi
    log_message "OceanBase observer and OBProxy are ready on ${OB_HOST}:${OB_PROXY_PORT}"
    return 0
}
