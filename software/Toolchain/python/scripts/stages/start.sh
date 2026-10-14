#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_python_runtime() {
    initialize_runtime || return $?
    [[ -x "${PYTHON_BIN}" ]] || {
        log_message "ERROR: CPython interpreter is unavailable: ${PYTHON_BIN}"
        return 40
    }
    "${PYTHON_BIN}" --version
    "${PYTHON_BIN}" -c "import ssl, zlib, ctypes" || {
        log_message "ERROR: CPython interpreter is missing ssl/zlib/ctypes modules"
        return 40
    }
    "${PYTHON_BIN}" -m pip --version || {
        log_message "ERROR: CPython interpreter has no usable pip"
        return 40
    }
    log_message "CPython official benchmark runtime is ready"
}
