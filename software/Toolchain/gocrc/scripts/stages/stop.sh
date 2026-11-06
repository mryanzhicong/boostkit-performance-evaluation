#!/usr/bin/env bash
# Stop stage: remove this run's private container and the private Go work
# directories (GOPATH, cloned openEuler golang tree, runtime caches).  Every
# removal is idempotent and guarded so a failed stage leaves no container behind
# without ever deleting anything outside PERF_WORK_DIR.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

cleanup_go_runtime_directory() {
    if [[ -z "${GO_RUNTIME_DIR}" ]]; then
        return 0
    fi
    if [[ "${GO_RUNTIME_DIR}" != "${GO_RUNTIME_ROOT}" || -z "${GO_RUNTIME_ROOT}" ]]; then
        log_message "ERROR: refusing to clean an unexpected Go runtime directory: ${GO_RUNTIME_DIR}"
        return 60
    fi
    [[ -d "${GO_RUNTIME_DIR}" ]] || return 0
    if ! chmod -R u+w "${GO_RUNTIME_DIR}" 2>/dev/null; then
        log_message "WARNING: cannot make the Go runtime directory writable for cleanup"
    fi
    if ! rm -rf -- "${GO_RUNTIME_DIR}"; then
        log_message "ERROR: failed to remove the private Go runtime directory: ${GO_RUNTIME_DIR}"
        return 60
    fi
    log_message "removed private Go runtime directory: ${GO_RUNTIME_DIR}"
}

cleanup_go_work_directories() {
    local directory
    for directory in "${GO_GOPATH}" "${GO_SRC_HOST_DIR}"; do
        [[ -n "${directory}" ]] || continue
        [[ -d "${directory}" ]] || continue
        case "${directory}" in
            "${PERF_WORK_DIR}"/*) ;;
            *)
                log_message "ERROR: refusing to clean a directory outside the work dir: ${directory}"
                return 60
                ;;
        esac
        if ! chmod -R u+w "${directory}" 2>/dev/null; then
            log_message "WARNING: cannot make the work directory writable for cleanup: ${directory}"
        fi
        if ! rm -rf -- "${directory}"; then
            log_message "ERROR: failed to remove the private Go work directory: ${directory}"
            return 60
        fi
        log_message "removed private Go work directory: ${directory}"
    done
}

stop_gocrc_runtime() {
    initialize_runtime || return $?
    configure_go_environment
    if ! command -v docker >/dev/null 2>&1; then
        log_message "Docker is unavailable; there is no private container to stop"
        cleanup_go_work_directories || return $?
        cleanup_go_runtime_directory || return $?
        return 0
    fi
    remove_gocrc_container || return $?
    cleanup_go_work_directories || return $?
    cleanup_go_runtime_directory || return $?
    log_message "Go benchmark stop stage completed"
}
