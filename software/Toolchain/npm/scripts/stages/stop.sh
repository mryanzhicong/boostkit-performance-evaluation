#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

process_is_ancestor_of_this_shell() {
    # A pattern based process lookup also matches the shell that carries the
    # pattern in its command line, so never signal this shell or any of its
    # parents.
    local target="$1" current="${PPID:-0}" depth=0
    while [[ "${current}" -gt 1 && "${depth}" -lt 64 ]]; do
        if [[ "${current}" == "${target}" ]]; then
            return 0
        fi
        current="$(awk '{print $4}' "/proc/${current}/stat" 2>/dev/null || true)"
        if [[ -z "${current}" ]]; then
            break
        fi
        depth=$((depth + 1))
    done
    return 1
}

stop_npm_runtime() {
    # npm is a short-lived command-line tool: every measured invocation is a
    # child process awaited by the timing wrapper, so there is no service to
    # shut down.  Stop only verifies that no measured run is still alive and
    # that the fixture trees are left in a known state.
    initialize_runtime || return $?
    local marker="${PERF_WORK_DIR}/running"
    if [[ -f "${marker}" ]]; then
        log_message "WARNING: a measured npm run left a marker behind: ${marker}"
        rm -f -- "${marker}"
    fi
    if [[ -z "${NPM_CLI_JS}" ]]; then
        log_message "ERROR: the npm launcher path is unknown; refusing a process scan"
        return 40
    fi
    local pid cmdline leftovers=0
    for pid in $(pgrep -f -- "${NPM_CLI_JS}" 2>/dev/null || true); do
        if [[ "${pid}" == "$$" ]] || (( pid <= 1 )) || process_is_ancestor_of_this_shell "${pid}"; then
            continue
        fi
        cmdline="$(tr '\0' ' ' < "/proc/${pid}/cmdline" 2>/dev/null || true)"
        case "${cmdline}" in
            *"${NPM_CLI_JS}"*) ;;
            *) continue ;;
        esac
        leftovers=$((leftovers + 1))
        log_message "WARNING: an npm process from this run is still alive (pid ${pid}); terminating it"
        kill -TERM "${pid}" 2>/dev/null || true
    done
    if (( leftovers == 0 )); then
        log_message "no measured npm process is still running"
    fi
    log_message "npm runtime stop completed"
    return 0
}
