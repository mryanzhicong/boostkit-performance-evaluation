#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_folly_runtime() {
    initialize_runtime || return $?
    [[ -x "${SERVER_BINARY}" && -x "${CLIENT_BINARY}" ]] || {
        log_message 'ERROR: AccLibBenchmark press_server/press_client is missing'
        return 40
    }
    [[ ! -e "${SERVICE_DIR}/server.pid" ]] || {
        log_message 'ERROR: a server PID file already exists for this run'
        return 40
    }
    local port
    port="$(python3 - <<'PYEOF'
import socket
with socket.socket() as listener:
    listener.bind(("127.0.0.1", 0))
    print(listener.getsockname()[1])
PYEOF
)"
    printf '%s\n' "${port}" > "${SERVICE_DIR}/port"
    log_message "starting AccLibBenchmark press_server on 127.0.0.1:${port}"
    "${SERVER_BINARY}" --num_io_threads=40 --num_cpu_threads=40 \
        --port="${port}" --use_io_uring=false \
        > "${RESULTS_DIR}/press_server.log" 2>&1 &
    local server_pid="$!" attempt
    printf '%s\n' "${server_pid}" > "${SERVICE_DIR}/server.pid"
    for attempt in {1..60}; do
        if python3 - "${port}" <<'PYEOF'
import socket, sys
try:
    with socket.create_connection(("127.0.0.1", int(sys.argv[1])), timeout=0.2):
        pass
except OSError:
    raise SystemExit(1)
PYEOF
        then
            log_message 'AccLibBenchmark press_server is ready'
            return 0
        fi
        if ! kill -0 "${server_pid}" 2>/dev/null; then
            log_message "ERROR: press_server exited; see ${RESULTS_DIR}/press_server.log"
            return 40
        fi
        sleep 1
    done
    log_message "ERROR: press_server did not listen; see ${RESULTS_DIR}/press_server.log"
    return 40
}
