#!/usr/bin/env bash
#
# Start stage for the catj case: prove that the staged runtime and the fixed
# inputs are exactly the ones recorded by the build stage.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

verify_node_runtime() {
    if [[ ! -x "${NODE_BIN}" ]]; then
        log_message "ERROR: pinned Node.js binary is missing: ${NODE_BIN}"
        return 40
    fi
    local reported
    reported="$("${NODE_BIN}" --version 2>/dev/null || true)"
    if [[ "${reported}" != "${NODE_VERSION}" ]]; then
        log_message "ERROR: expected node ${NODE_VERSION}, found ${reported:-unknown}"
        return 40
    fi
    if [[ ! -f "${APP_DIR}/node_modules/catj/catj.js" ]]; then
        log_message "ERROR: staged catj CLI is missing"
        return 40
    fi
}

verify_runtime_record() {
    if [[ ! -f "${RUNTIME_JSON}" ]]; then
        log_message "ERROR: runtime record is missing: ${RUNTIME_JSON}"
        return 40
    fi
    if ! python3 "${SCRIPT_DIR}/scripts/results/check_runtime.py" \
        --scenarios "${SCENARIOS_FILE}" \
        --runtime "${RUNTIME_JSON}" \
        --input-dir "${INPUT_DIR}" \
        --node-bin "${NODE_BIN}"; then
        return 40
    fi
}

start_catj_runtime() {
    initialize_runtime || return $?
    validate_reps || return $?
    check_architecture || return $?
    verify_node_runtime || return $?
    verify_runtime_record || return $?
    log_message "catj ${SOFTWARE_VERSION} measurement runtime is ready (${#CATJ_SCENARIOS[@]} scenarios, node ${NODE_VERSION})"
}
