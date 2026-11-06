#!/usr/bin/env bash
# ==============================================================================
# numpy start stage -- validate the containerised payload before measuring.
# ==============================================================================
# Nothing is measured here.  The stage proves that the container started by the
# build stage really carries the pinned interpreter, the pinned NumPy baseline,
# the vendored ASV suite (manifest-checked) and a complete ASV discovery for the
# 1256 shipped benchmark ids, so the expensive test stage cannot start from a
# half-built environment.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# numpy_verify_runtime_payload lives in common.sh because the test stage runs
# the same pre-flight before it starts the multi-minute benchmark run.

# ASV only knows which benchmark combinations exist after it has imported the
# suite.  One cheap benchmark is measured to force that discovery, then its
# result is discarded so the test stage records the only measurement that counts.
numpy_discover_benchmarks() {
    local log first_regex
    local -a exact=()
    log="${RESULTS_DIR}/asv-discover.log"
    mapfile -t exact < <(numpy_container_exec "${VENV_PY}" \
        "${SCRIPT_DIR}/scripts/benchmarks/select_benchmarks.py" \
        --list "${ASV_LIST}" --emit-bench-args) || {
        log_message "ERROR: cannot expand the benchmark id list"
        return 50
    }
    if [ "${#exact[@]}" -lt 1200 ]; then
        log_message "ERROR: the benchmark id list expanded to only ${#exact[@]} entries"
        return 50
    fi
    first_regex="${exact[0]}"
    log_message "forcing ASV discovery with ${#exact[@]} id regexes staged"
    numpy_container_exec_at "${ASV_DIR}" env "${NUMPY_MEASUREMENT_ENV[@]}" \
        "HOME=${PERF_WORK_DIR}/home" "${ASV_BIN}" run --python=same \
        --set-commit-hash "${NUMPY_BASELINE_COMMIT}" --no-pull --quick \
        -b "${first_regex}" > "${log}" 2>&1 || {
        log_message "ERROR: ASV discovery failed, see asv-discover.log"
        tail -40 "${log}" || true
        return 50
    }
    if [ ! -s "${ASV_RESULTS_DIR}/benchmarks.json" ]; then
        log_message "ERROR: ASV wrote no benchmarks.json during discovery"
        return 50
    fi
    find "${ASV_RESULTS_DIR}" -name '*.json' ! -name 'benchmarks.json' \
        ! -name 'machine.json' -delete 2>/dev/null || true
    log_message "ASV discovery completed; stale measurement records removed"
}

# Resolve all shipped ids against the discovered suite.  This is the same
# resolution the strict parser repeats after the measurement, so a mismatch is
# reported before the multi-minute benchmark run starts.
numpy_resolve_expected_set() {
    local summary
    summary="$(numpy_container_exec "${VENV_PY}" \
        "${SCRIPT_DIR}/scripts/benchmarks/select_benchmarks.py" \
        --list "${ASV_LIST}" \
        --benchmarks "${ASV_RESULTS_DIR}/benchmarks.json" \
        --emit-expected "${RUNS_DIR}/expected.json" \
        --json)" || {
        log_message "ERROR: the shipped benchmark ids do not resolve against the ASV suite"
        return 50
    }
    printf '%s\n' "${summary}" | tee "${RESULTS_DIR}/asv-selection.json"
    log_message "benchmark selection resolved: $(printf '%s' "${summary}" | tr '\n' ' ')"
}

start_numpy_runtime() {
    initialize_runtime || return $?
    check_architecture || return $?
    validate_reps || return $?
    numpy_configure_container || return $?
    numpy_require_host_tools || return $?
    require_numpy_docker || return $?
    check_numpy_container || return 40

    numpy_verify_runtime_payload || return $?
    numpy_discover_benchmarks || return $?
    numpy_resolve_expected_set || return $?
    log_message "start stage complete"
}
