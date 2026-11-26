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


def _cinderx_probe(left, right):
    return left + right


# cinderx.jit publishes state and control entry points only; there is no
# is_available() probe. An enabled flag proves configuration, so compile one
# trivial function to prove the native backend can emit and publish code.
if not jit.is_enabled():
    raise SystemExit(
        "CinderX JIT is not running; the native backend is missing from this "
        "build or dispatch is off (check CINDERX_PLUGIN_ENABLE, PYTHONJITAUTO "
        "and PYTHONJITDISABLE)"
    )
try:
    jit.force_compile(_cinderx_probe)
except Exception as exc:
    raise SystemExit(
        f"CinderX JIT cannot compile a trivial function: {type(exc).__name__}: {exc}"
    ) from None
if not jit.is_jit_compiled(_cinderx_probe):
    raise SystemExit("CinderX JIT compiled a trivial function but did not publish it")
print(f"CinderX initialized: {cinderx.__file__}")
print(f"CinderX JIT enabled: {jit.is_enabled()}, probe compiled: {jit.is_jit_compiled(_cinderx_probe)}")
' || {
            log_message "ERROR: CinderX is not active in the private CPython"
            return 40
        }
    fi
    log_message "CPython official benchmark runtime is ready"
}
