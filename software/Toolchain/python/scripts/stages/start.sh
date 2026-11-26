#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_python_runtime() {
    initialize_runtime || return $?
    python_load_expected_source || return $?
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
    if [[ "${PERF_VARIANT}" == optimized ]]; then
        log_message "pinned CinderX source: ${PYTHON_EXPECTED_COMMIT} (${PYTHON_EXPECTED_BRANCH})"
        log_message "checking CinderX activation in the private CPython"
        CINDERX_PLUGIN_ENABLE="${CINDERX_PLUGIN_ENV}" \
        PYTHONJITAUTO="${CINDERX_PYTHONJITAUTO}" \
            "${PYTHON_BIN}" -c '
import cinderx
import cinderx.jit as jit

if not cinderx.is_initialized():
    raise SystemExit(f"CinderX is not initialized: {cinderx.get_import_error()}")
if not jit.is_available():
    raise SystemExit("CinderX JIT native APIs are not available in this build")
if not jit.is_enabled():
    raise SystemExit("CinderX JIT is not enabled; check CINDERX_PLUGIN_ENABLE and PYTHONJITAUTO")
print(f"CinderX initialized: {cinderx.__file__}")
print(f"CinderX JIT available: {jit.is_available()}, enabled: {jit.is_enabled()}")
' || {
            log_message "ERROR: CinderX is not active in the private CPython"
            return 40
        }
    fi
    log_message "CPython official benchmark runtime is ready"
}
