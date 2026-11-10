#!/usr/bin/env bash
# Start stage: bring up the measured runtime inside the private container.
#
#   1. prepare the run directory tree and copy the kit's LoCoMo dataset;
#   2. start the deterministic OpenAI-compatible provider mock (LLM + embedding)
#      and verify it answers both endpoints;
#   3. generate the kit's ov.conf with the kit's own prepare_run.py;
#   4. start the OpenViking server through the kit's agfs_timing harness, so the
#      AGFS spans are recorded exactly like the upstream protocol;
#   5. wait for /health and run the kit's provider smoke test.
#
# The server is started once for the measured protocol run; the test stage drives
# the kit protocol against this already healthy runtime.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

prepare_openviking_run_dirs() {
    openviking_run "mkdir -p '${OPENVIKING_RUN_ROOT}/raw' '${OPENVIKING_RUN_ROOT}/metrics' \
        '${OPENVIKING_RUN_ROOT}/logs' '${OPENVIKING_RUN_ROOT}/reports' '${OPENVIKING_RUN_ROOT}/result' \
        '${OPENVIKING_RUN_ROOT}/workspace'" || return 40
    openviking_run "cp '${OPENVIKING_KIT_DIR}/data/locomo10.json' '${OPENVIKING_RUN_ROOT}/raw/locomo10.json'" || return 40
}

stop_openviking_mock_provider() {
    openviking_run "if [ -f '${PERF_WORK_DIR}/mock.pid' ]; then kill -TERM \"\$(cat '${PERF_WORK_DIR}/mock.pid')\" 2>/dev/null || true; rm -f '${PERF_WORK_DIR}/mock.pid'; fi" || true
    openviking_run "pkill -f 'benchmark/mock_openai.py' || true" || true
}

start_openviking_mock_provider() {
    stop_openviking_mock_provider
    log_message "starting the deterministic provider mock on port ${OPENVIKING_MOCK_PORT}"
    openviking_run "nohup python3 '${SCRIPT_DIR}/benchmark/mock_openai.py' \
        --host 127.0.0.1 --port '${OPENVIKING_MOCK_PORT}' \
        --dimension '${OPENVIKING_MOCK_EMBEDDING_DIMENSION}' \
        > '${OPENVIKING_RUN_ROOT}/logs/mock.log' 2>&1 & echo \$! > '${PERF_WORK_DIR}/mock.pid'" || return 40
    local attempts=60 index=0
    while (( index < attempts )); do
        if openviking_http_ready "http://127.0.0.1:${OPENVIKING_MOCK_PORT}/health"; then
            log_message "provider mock is healthy (pid=$(cat "${PERF_WORK_DIR}/mock.pid" 2>/dev/null || echo unknown))"
            return 0
        fi
        index=$((index + 1))
        sleep 1
    done
    openviking_run "tail -30 '${OPENVIKING_RUN_ROOT}/logs/mock.log'" || true
    log_message "ERROR: the provider mock did not become healthy"
    return 40
}

prepare_openviking_config() {
    local run_root="${1:-${OPENVIKING_RUN_ROOT}}"
    log_message "generating ov.conf with the kit's prepare_run.py for ${run_root}"
    openviking_run "env RUN_ROOT='${run_root}' python3 '${OPENVIKING_KIT_DIR}/harness/prepare_run.py'" || {
        log_message "ERROR: the kit configuration could not be generated"
        return 40
    }
    openviking_run "test -s '${run_root}/ov.conf'" || {
        log_message "ERROR: ov.conf was not written"
        return 40
    }
    openviking_run "env RUN_ROOT='${run_root}' python3 '${OPENVIKING_KIT_DIR}/harness/provider_smoke.py'" || {
        log_message "ERROR: the provider smoke test failed"
        return 40
    }
}

stop_openviking_server() {
    openviking_run "if [ -f '${PERF_WORK_DIR}/server.pid' ]; then kill -TERM \"\$(cat '${PERF_WORK_DIR}/server.pid')\" 2>/dev/null || true; rm -f '${PERF_WORK_DIR}/server.pid'; fi" || true
    openviking_run "pkill -f 'harness/agfs_timing.py' || true" || true
}

start_openviking_server() {
    local run_root="${1:-${OPENVIKING_RUN_ROOT}}" config="${2:-}"
    [[ -n "${config}" ]] || config="${run_root}/ov.conf"
    stop_openviking_server
    log_message "starting the OpenViking server through the kit's agfs_timing harness on port ${OPENVIKING_SERVICE_PORT} (run_root=${run_root})"
    openviking_run "nohup env RUN_ROOT='${run_root}' OPENVIKING_CONFIG_FILE='${config}' python3 '${OPENVIKING_KIT_DIR}/harness/agfs_timing.py' \
        --config '${config}' \
        > '${run_root}/logs/server.stdout.log' 2>&1 & echo \$! > '${PERF_WORK_DIR}/server.pid'" || return 40
    if ! wait_for_openviking_http "http://127.0.0.1:${OPENVIKING_SERVICE_PORT}/health" 180; then
        openviking_run "tail -60 '${run_root}/logs/server.stdout.log'" || true
        log_message "ERROR: the OpenViking server did not become healthy"
        return 40
    fi
    log_message "OpenViking server is healthy (pid=$(cat "${PERF_WORK_DIR}/server.pid" 2>/dev/null || echo unknown))"
}

start_openviking_runtime() {
    initialize_runtime || return $?
    check_openviking_container || return $?
    prepare_openviking_run_dirs || return $?
    start_openviking_mock_provider || return $?
    prepare_openviking_config || return $?
    start_openviking_server || return $?
    openviking_run "test -s '${OPENVIKING_RUN_ROOT}/metrics/env_info.json'" || {
        log_message "ERROR: the kit environment snapshot is missing"
        return 40
    }
    log_message "runtime is ready: mock=${OPENVIKING_MOCK_PORT} service=${OPENVIKING_SERVICE_PORT} run_root=${OPENVIKING_RUN_ROOT}"
}
