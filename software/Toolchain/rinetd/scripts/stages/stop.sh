#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

RINETD_PIDFILE="${RESULTS_DIR}/rinetd.pid"
RINETD_PORTS_FILE="${RESULTS_DIR}/ports.env"

# A backgrounded in-container helper is reparented to the container's init
# process (``sleep infinity``), which never reaps it; a finished helper therefore
# stays visible as a zombie and ``kill -0`` keeps succeeding.  Treat zombies as
# exited, otherwise the stop/test stages would wait forever.
container_pid_alive() {
    local pid="$1"
    [[ "${pid}" =~ ^[0-9]+$ ]] || return 1
    rinetd_container_exec sh -c "
        kill -0 '${pid}' 2>/dev/null || exit 1
        state=\$(sed -n 's/^State:[[:space:]]*//p' /proc/'${pid}'/status 2>/dev/null)
        [ \"\${state%% *}\" != Z ]
    " >/dev/null 2>&1
}

port_is_closed() {
    local port="$1"
    rinetd_container_exec python3 -c '
import socket
import sys

port = int(sys.argv[1])
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.settimeout(0.5)
try:
    sock.connect(("127.0.0.1", port))
except OSError:
    sys.exit(0)
finally:
    sock.close()
sys.exit(1)
' "${port}"
}

stop_rinetd_runtime() {
    local pid="" index
    initialize_runtime || return $?

    # Stop the forwarding service first (it lives inside the private container),
    # verify its ports are closed, and only then remove the container.
    if [[ -f "${RINETD_PIDFILE}" ]]; then
        pid="$(cat "${RINETD_PIDFILE}" 2>/dev/null || true)"
    fi
    if container_pid_alive "${pid}"; then
        log_message "stopping rinetd inside the private container (pid ${pid})"
        rinetd_container_exec sh -c "kill -TERM ${pid}" >/dev/null 2>&1 || true
        for _ in $(seq 1 200); do
            container_pid_alive "${pid}" || break
            sleep 0.05
        done
        if container_pid_alive "${pid}"; then
            log_message "WARNING: rinetd did not exit after SIGTERM; sending SIGKILL"
            rinetd_container_exec sh -c "kill -KILL ${pid}" >/dev/null 2>&1 || true
        fi
        for _ in $(seq 1 100); do
            container_pid_alive "${pid}" || break
            sleep 0.05
        done
        if container_pid_alive "${pid}"; then
            log_message "ERROR: rinetd process ${pid} is still alive"
            return 60
        fi
        log_message "rinetd stopped"
    else
        log_message "no running rinetd instance to stop"
    fi
    rm -f -- "${RINETD_PIDFILE}"

    if [[ -f "${RINETD_PORTS_FILE}" ]]; then
        # shellcheck disable=SC1090
        source "${RINETD_PORTS_FILE}"
        local throughput_listen="${RINETD_THROUGHPUT_LISTEN_PORT:-}"
        local latency_listen="${RINETD_LATENCY_LISTEN_PORT:-}"
        if [[ -n "${throughput_listen}" ]] && ! port_is_closed "${throughput_listen}"; then
            log_message "ERROR: throughput listen port ${throughput_listen} is still open"
            return 60
        fi
        if [[ -n "${latency_listen}" ]] && ! port_is_closed "${latency_listen}"; then
            log_message "ERROR: latency listen port ${latency_listen} is still open"
            return 60
        fi
    fi

    remove_rinetd_container || return $?
    log_message "stop stage: rinetd stopped, private container removed"
    return 0
}
