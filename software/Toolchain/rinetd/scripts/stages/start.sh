#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

RINETD_CONFIG="${RESULTS_DIR}/rinetd.conf"
RINETD_PIDFILE="${RESULTS_DIR}/rinetd.pid"
RINETD_STDOUT="${RESULTS_DIR}/rinetd.stdout.log"
RINETD_PORTS_FILE="${RESULTS_DIR}/ports.env"

# The forwarding service itself runs inside this task's private container; the
# container uses the host network namespace, so the loopback ports it listens on
# are the same ports the container-native benchmark client connects to.
pick_free_ports() {
    rinetd_container_exec python3 -c '
import socket
def free_port():
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        sock.bind(("127.0.0.1", 0))
        return sock.getsockname()[1]
    finally:
        sock.close()
ports = []
while len(ports) < 4:
    candidate = free_port()
    if candidate not in ports:
        ports.append(candidate)
print("\n".join(str(port) for port in ports))
'
}

wait_for_listener() {
    local port="$1" timeout_seconds="${2:-15}"
    rinetd_container_exec python3 -c '
import socket
import sys
import time

port = int(sys.argv[1])
deadline = time.time() + float(sys.argv[2])
while time.time() < deadline:
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(0.2)
    try:
        sock.connect(("127.0.0.1", port))
        sys.exit(0)
    except OSError:
        time.sleep(0.02)
    finally:
        sock.close()
sys.exit(1)
' "${port}" "${timeout_seconds}"
}

stop_existing_rinetd() {
    if [[ -f "${RINETD_PIDFILE}" ]]; then
        local previous
        previous="$(cat "${RINETD_PIDFILE}" 2>/dev/null || true)"
        if [[ "${previous}" =~ ^[0-9]+$ ]]; then
            if rinetd_container_exec sh -c "kill -0 ${previous}" >/dev/null 2>&1; then
                log_message "stopping a stale rinetd instance (pid ${previous})"
                rinetd_container_exec sh -c "kill -TERM ${previous}" >/dev/null 2>&1 || true
                for _ in $(seq 1 100); do
                    rinetd_container_exec sh -c "kill -0 ${previous}" >/dev/null 2>&1 || break
                    sleep 0.05
                done
                rinetd_container_exec sh -c "kill -KILL ${previous}" >/dev/null 2>&1 || true
            fi
        fi
        rm -f -- "${RINETD_PIDFILE}"
    fi
}

start_rinetd_runtime() {
    local ports throughput_listen throughput_backend latency_listen latency_backend
    local pid attempt

    initialize_runtime || return $?

    check_rinetd_container || return $?

    if ! rinetd_container_exec test -x "${RINETD_BIN}"; then
        log_message "ERROR: rinetd binary is unavailable: ${RINETD_BIN}"
        return 40
    fi
    if ! rinetd_container_exec test -x "${RINETD_BENCH_BIN}"; then
        log_message "ERROR: benchmark harness is unavailable: ${RINETD_BENCH_BIN}"
        return 40
    fi
    stop_existing_rinetd

    for attempt in $(seq 1 5); do
        ports="$(pick_free_ports)" || {
            log_message "ERROR: cannot pick free loopback ports"
            return 40
        }
        mapfile -t chosen <<<"${ports}"
        throughput_listen="${chosen[0]}"
        throughput_backend="${chosen[1]}"
        latency_listen="${chosen[2]}"
        latency_backend="${chosen[3]}"

        cat > "${RINETD_CONFIG}" <<CONF
logfile ${RESULTS_DIR}/rinetd.log
127.0.0.1 ${throughput_listen} 127.0.0.1 ${throughput_backend}
127.0.0.1 ${latency_listen} 127.0.0.1 ${latency_backend}
CONF
        : > "${RINETD_STDOUT}"
        rm -f -- "${RINETD_PIDFILE}"
        rinetd_container_exec sh -c \
            "setsid '${RINETD_BIN}' -c '${RINETD_CONFIG}' -f >'${RINETD_STDOUT}' 2>&1 & echo \$! >'${RINETD_PIDFILE}'" || {
            log_message "ERROR: cannot launch rinetd inside the private container"
            return 40
        }
        pid="$(cat "${RINETD_PIDFILE}" 2>/dev/null || true)"

        if [[ "${pid}" =~ ^[0-9]+$ ]] && \
            rinetd_container_exec sh -c "kill -0 ${pid}" >/dev/null 2>&1 && \
            wait_for_listener "${throughput_listen}" 15 && \
            wait_for_listener "${latency_listen}" 15; then
            cat > "${RINETD_PORTS_FILE}" <<PORTS
RINETD_THROUGHPUT_LISTEN_PORT=${throughput_listen}
RINETD_THROUGHPUT_BACKEND_PORT=${throughput_backend}
RINETD_LATENCY_LISTEN_PORT=${latency_listen}
RINETD_LATENCY_BACKEND_PORT=${latency_backend}
PORTS
            log_message "rinetd is listening inside the container: throughput 127.0.0.1:${throughput_listen} -> :${throughput_backend}, latency 127.0.0.1:${latency_listen} -> :${latency_backend} (pid ${pid})"
            return 0
        fi

        log_message "WARNING: rinetd did not come up on attempt ${attempt}/5; retrying with different ports"
        if [[ "${pid}" =~ ^[0-9]+$ ]]; then
            rinetd_container_exec sh -c "kill -TERM ${pid}" >/dev/null 2>&1 || true
            for _ in $(seq 1 100); do
                rinetd_container_exec sh -c "kill -0 ${pid}" >/dev/null 2>&1 || break
                sleep 0.05
            done
            rinetd_container_exec sh -c "kill -KILL ${pid}" >/dev/null 2>&1 || true
        fi
        rm -f -- "${RINETD_PIDFILE}"
    done
    log_message "ERROR: rinetd failed to start after 5 attempts"
    if [[ -s "${RINETD_STDOUT}" ]]; then
        tail -n 40 -- "${RINETD_STDOUT}" | while IFS= read -r line; do log_message "  ${line}"; done
    fi
    return 40
}
