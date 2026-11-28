#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Bazel marks declared directory outputs read-only, so the framework's later
# `find "${PERF_WORK_ROOT}" -mindepth 1 -delete` cannot unlink their contents:
# removing an entry needs write permission on the parent directory. Give the owner
# write permission back before this stage ends so the dedicated runner can be
# cleaned instead of being quarantined.
release_bazel_output_permissions() {
    local target="${TF_SOURCE_DIR}/output"
    if [[ ! -d "${target}" ]]; then
        return 0
    fi
    find "${target}" -type d ! -perm -u+w -exec chmod u+w {} + 2>/dev/null || true
    log 'released write permission on the read-only Bazel output directories'
}

stop_tensorflow_runtime() {
    initialize_runtime || return $?
    local status=0
    if ! command -v docker >/dev/null 2>&1; then
        log 'no Docker client; no managed TensorFlow container to stop'
    else
        if docker container inspect "${TF_CONTAINER_NAME}" >/dev/null 2>&1; then
            docker logs "${TF_CONTAINER_NAME}" > "${RESULTS_DIR}/container_runtime.log" 2>&1 || true
        fi
        remove_tensorflow_container || status=$?
        log 'managed TensorFlow container stopped'
    fi
    release_bazel_output_permissions || status=$?
    return "${status}"
}
